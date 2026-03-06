//
//  Observable+SSE.swift
//  nexus
//
//  SSE (Server-Sent Events) 流解析扩展
//  Created by Claude on 2024-03-06.
//

import Foundation
import RxSwift

// MARK: - SSE 事件数据结构

/// SSE 事件数据模型
///
/// 表示一个完整的 SSE 事件，包含 event 类型和 data 内容。
///
/// ## 属性说明
/// - `event`: 事件类型标识符，对应 SSE 的 `event:` 字段，可选
/// - `data`: 事件数据内容，对应 SSE 的 `data:` 字段，可选（支持多行合并）
///
/// ## 示例
/// ```swift
/// // 单行 data
/// SSEEventData(event: "message", data: "{\"text\": \"hello\"}")
///
/// // 多行 data（自动用 \n 连接）
/// SSEEventData(event: "log", data: "line1\nline2\nline3")
/// ```
public struct SSEEventData {
    /// 事件类型，对应 `event:` 字段
    let event: String?

    /// 事件数据，对应 `data:` 字段（多行时用 `\n` 连接）
    let data: String?

    /// 是否为空事件（event 和 data 都为空）
    var isEmpty: Bool {
        return event == nil && data == nil
    }
}

// MARK: - Observable SSE 扩展

public extension ObservableType where Element == String {
    /// 将 SSE 文本流转换为结构化的事件流
    ///
    /// 该方法将上游的原始文本块（可能是分块传输）解析为符合 SSE 规范的事件对象。
    ///
    /// ## 特性
    /// - ✅ **流式解析**: 收到完整事件（以 `\n\n` 结尾）立即发送，无需等待全部数据
    /// - ✅ **分块处理**: 自动处理 TCP 分块导致的事件被拆分到多个 chunk 的情况
    /// - ✅ **多行 data 合并**: 支持多个 `data:` 行，按 SSE 规范用 `\n` 连接
    /// - ✅ **换行符兼容**: 支持 `\n`、`\r\n`、`\r` 三种换行符格式
    /// - ✅ **注释过滤**: 自动忽略以 `:` 开头的注释行
    /// - ✅ **流结束保护**: 流结束时自动处理残留 buffer 中的最后一个事件
    /// - ✅ **空格处理**: 按 SSE 规范只移除字段值前的一个空格
    ///
    /// ## SSE 格式示例
    /// ```
    /// event: session_started
    /// data: {"user_id": "76ca6ba98c4d"}
    ///
    /// event: progress
    /// data: {"percent": 45}
    ///
    /// event: log
    /// data: {"msg": "第一步"}
    /// data: {"msg": "第二步"}
    ///
    /// ```
    ///
    /// ## 支持的边界场景
    ///
    /// | 场景 | 支持 | 说明 |
    /// |------|------|------|
    /// | 事件跨 chunk 拆分 | ✅ | 自动缓存并拼接 |
    /// | 一个 chunk 多个事件 | ✅ | 循环解析并逐个发送 |
    /// | 多行 `data:` | ✅ | 用 `\n` 连接合并 |
    /// | `\r\n` / `\r` 换行 | ✅ | 统一转为 `\n` 处理 |
    /// | 注释行 (`:xxx`) | ✅ | 自动忽略 |
    /// | 流结束无 `\n\n` | ✅ | 自动追加终止符处理残留 |
    /// | 只有 `event:` 无 `data:` | ✅ | `data` 为 `nil` |
    /// | 只有 `data:` 无 `event:` | ✅ | `event` 为 `nil` |
    /// | 空事件块 | ✅ | 自动过滤不发送 |
    ///
    /// ## 发送时机
    /// - 每收到一个 chunk 立即尝试解析
    /// - 找到完整事件（以 `\n\n` 分隔）时立即向下游 `onNext` 发送
    /// - 未完成的事件保留在 buffer 中等待后续 chunk
    ///
    /// ## 使用示例
    /// ```swift
    /// // 配合 URLSession 的流式响应使用
    /// sseTextStream
    ///     .mapSSEEventData()
    ///     .subscribe(onNext: { event in
    ///         print("Event: \(event.event ?? "nil")")
    ///         print("Data: \(event.data ?? "nil")")
    ///     })
    /// ```
    ///
    /// - Returns: 解析后的 SSE 事件流 `Observable<SSEEventData>`
    func mapSSEEventData() -> Observable<SSEEventData> {
        return self
            // 流结束时追加 \n\n，确保残留 buffer 被处理
            .concat(Observable.just("\n\n"))
            // 使用 scan 维护缓冲区状态，处理跨数据块的事件
            .scan((buffer: "", events: [SSEEventData]())) { state, text in
                // 统一换行符：\r\n 和 \r 都转为 \n
                let normalizedText = text
                    .replacingOccurrences(of: "\r\n", with: "\n")
                    .replacingOccurrences(of: "\r", with: "\n")

                var buffer = state.buffer + normalizedText
                var events: [SSEEventData] = []

                // SSE 事件以双换行符 "\n\n" 分隔
                while let range = buffer.range(of: "\n\n") {
                    let eventBlock = String(buffer[..<range.lowerBound])
                    buffer = String(buffer[range.upperBound...])

                    let eventData = Self.parseSSEBlock(eventBlock)
                    if !eventData.isEmpty {
                        events.append(eventData)
                    }
                }

                return (buffer: buffer, events: events)
            }
            // 展开每次解析出的事件数组
            .flatMap { Observable.from($0.events) }
    }

    /// 解析单个 SSE 事件块
    ///
    /// 将一个完整的事件文本块（不含终止符 `\n\n`）解析为 `SSEEventData` 对象。
    ///
    /// ## 解析规则
    /// - `event:` 行 → 提取为 `event` 属性
    /// - `data:` 行 → 收集到数组，最终用 `\n` 连接为 `data` 属性
    /// - `:` 开头 → 注释行，忽略
    /// - 其他行 → 忽略（如 `id:`、`retry:` 等未实现的字段）
    ///
    /// - Parameter block: 单个事件的文本内容（不含 `\n\n` 终止符）
    /// - Returns: 解析后的事件对象，若 event 和 data 均为空则 `isEmpty` 为 true
    private static func parseSSEBlock(_ block: String) -> SSEEventData {
        var eventType: String?
        var dataLines: [String] = []

        let lines = block.split(separator: "\n", omittingEmptySubsequences: false)
        for line in lines {
            if line.hasPrefix(":") {
                // SSE 注释行，忽略
                continue
            } else if line.hasPrefix("event:") {
                // SSE 规范：只移除字段名后的一个空格
                eventType = Self.parseFieldValue(String(line.dropFirst(6)))
            } else if line.hasPrefix("data:") {
                // 多行 data 收集到数组
                dataLines.append(Self.parseFieldValue(String(line.dropFirst(5))))
            }
        }

        let eventData = dataLines.isEmpty ? nil : dataLines.joined(separator: "\n")
        return SSEEventData(event: eventType, data: eventData)
    }

    /// 按 SSE 规范解析字段值
    ///
    /// SSE 规范规定：如果字段值以空格开头，应移除**一个**空格。
    /// 这与 `trimmingCharacters` 不同，后者会移除所有前后空格。
    ///
    /// ## 示例
    /// ```
    /// "data: hello"  → " hello" → "hello"   (移除一个空格)
    /// "data:  hello" → "  hello" → " hello" (只移除一个，保留一个)
    /// "data:hello"   → "hello" → "hello"    (无空格，不处理)
    /// ```
    ///
    /// - Parameter value: 字段名后的原始值（如 `data:` 后的部分）
    /// - Returns: 处理后的字段值
    private static func parseFieldValue(_ value: String) -> String {
        if value.hasPrefix(" ") {
            return String(value.dropFirst())
        }
        return value
    }
}
