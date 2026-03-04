//
//  EventLimiter.swift
//  xxf_ios
//  限流工具（Throttle & Debounce）
//  Created by xxf on 6/19.
//

import Foundation

/// 线程安全的事件限流器
/// 提供 Throttle（节流）和 Debounce（防抖）功能，支持多 key 管理
public final class EventLimiter {
    public nonisolated(unsafe) static let shared = EventLimiter()

    /// 记录每个 key 上次触发的时间（用于节流）
    private var lastFire = ConcurrentDictionary<String, TimeInterval>()

    /// 记录每个 key 对应的延迟任务（用于防抖）
    private var workItems = ConcurrentDictionary<String, DispatchWorkItem>()

    private init() {}

    // MARK: - Throttle

    /// 节流方法（Throttle）
    ///
    /// 多次触发同一 key 时，只会在固定时间间隔后执行一次闭包
    /// - Parameters:
    ///   - key: 唯一标识，用于区分不同事件源,可使用: sourceCodeLocationID()
    ///   - interval: 节流间隔，使用 TimeUnit 类型，默认 0.5 秒
    ///   - action: 立即执行闭包
    public func throttle(key: String = String(describing: EventLimiter.self), interval: TimeInterval = 0.5, action: () -> Void) {
        let now = Date().timeIntervalSince1970
        let last = lastFire[key] ?? 0
        if now - last >= interval {
            lastFire[key] = now
            action()
        }
    }

    // MARK: - Debounce

    /// 防抖方法（Debounce）
    ///
    /// 多次触发同一 key 时，只在最后一次触发后延迟执行闭包
    /// - Parameters:
    ///   - key: 唯一标识，用于区分不同事件源,可使用: sourceCodeLocationID()
    ///   - delay: 延迟时间，使用 TimeUnit 类型，默认 0.5 秒
    ///   - queue: 执行闭包的队列，默认主队列
    ///   - action: 延迟执行闭包（需要 @escaping）
    public func debounce(key: String = String(describing: EventLimiter.self), delay: TimeInterval = 0.5, queue: DispatchQueue = .main, action: @escaping () -> Void) {
        workItems[key]?.cancel()
        let workItem = DispatchWorkItem {
            action()
            self.workItems.remove(key)
        }
        workItems[key] = workItem
        queue.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    /// 取消指定 key 的防抖任务
    /// - Parameter key: 需要取消的 key
    public func cancel(key: String) {
        workItems[key]?.cancel()
        workItems.remove(key)
    }
}
