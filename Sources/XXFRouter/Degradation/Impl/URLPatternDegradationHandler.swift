//
//  URLPatternDegradationHandler.swift
//  xxf_ios
//
//  Created by xxf on 5/9.
//

import Foundation

// MARK: - 内置降级处理器

/// URL降级处理器，处理特定URL模式的降级
public final class URLPatternDegradationHandler: DegradationHandler, @unchecked Sendable {
    public let name: String
    public let priority: Int
    public let strategy: DegradationStrategy

    private let pattern: String
    private let handler: @Sendable (RouteContext) -> DegradationResult

    /// 创建URL模式降级处理器
    /// - Parameters:
    ///   - pattern: URL模式（支持正则表达式）
    ///   - name: 处理器名称
    ///   - priority: 优先级
    ///   - strategy: 降级策略
    ///   - handler: 处理闭包
    public init(
        pattern: String,
        name: String = "URLPatternDegradationHandler",
        priority: Int = 0,
        strategy: DegradationStrategy = .custom,
        handler: @escaping @Sendable (RouteContext) -> DegradationResult
    ) {
        self.pattern = pattern
        self.name = name
        self.priority = priority
        self.strategy = strategy
        self.handler = handler
    }

    public func canHandle(context: RouteContext) -> Bool {
        // 尝试正则匹配
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(context.url.startIndex..., in: context.url)
            return regex.firstMatch(in: context.url, options: [], range: range) != nil
        }

        // 简单字符串包含检查
        return context.url.lowercased().contains(pattern.lowercased())
    }

    public func handle(context: RouteContext) -> DegradationResult {
        return handler(context)
    }
}
