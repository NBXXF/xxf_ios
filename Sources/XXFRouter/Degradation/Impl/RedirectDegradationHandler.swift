//
//  RedirectDegradationHandler.swift
//  xxf_ios
//
//  Created by xxf on 5/9.
//

/// 重定向降级处理器
public final class RedirectDegradationHandler: DegradationHandler, @unchecked Sendable {
    public let name = "RedirectDegradationHandler"
    public let priority: Int
    public let strategy: DegradationStrategy

    private let targetURL: String
    private let condition: (@Sendable (RouteContext) -> Bool)?

    /// 创建重定向降级处理器
    /// - Parameters:
    ///   - targetURL: 重定向目标URL
    ///   - priority: 优先级
    ///   - condition: 触发条件（可选）
    public init(
        targetURL: String,
        priority: Int = 0,
        condition: (@Sendable (RouteContext) -> Bool)? = nil
    ) {
        self.targetURL = targetURL
        self.priority = priority
        self.strategy = .redirect(url: targetURL)
        self.condition = condition
    }

    public func canHandle(context: RouteContext) -> Bool {
        if let condition = condition {
            return condition(context)
        }
        return true
    }

    public func handle(context: RouteContext) -> DegradationResult {
        return .redirect(url: targetURL)
    }
}
