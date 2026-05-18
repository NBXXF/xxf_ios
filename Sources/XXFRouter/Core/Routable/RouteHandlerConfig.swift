//
//  RouteHandlerConfig.swift
//  XXFRouter
//
//  路由处理器配置
//  Created by XXF on 2024
//

/// 路由处理器配置，用于批量注册处理器
///
/// 使用示例：
/// ```swift
/// let configs: [RouteHandlerConfig] = [
///     RouteHandlerConfig(pattern: "app://logout") { _ in
///         AuthService.shared.logout()
///         return true
///     },
///     RouteHandlerConfig(pattern: "app://share") { ctx in
///         ShareManager.share(content: ctx.string(for: "content"))
///         return true
///     }
/// ]
/// router.register(handlers: configs)
/// ```
public struct RouteHandlerConfig: Sendable {
    /// 路由模式
    public let pattern: String
    /// 路由标志位
    public let flags: RouteFlags
    /// 优先级
    public let priority: Int
    /// 处理器闭包
    public let handler: @Sendable (RouteContext) -> Bool

    /// 创建路由处理器配置
    /// - Parameters:
    ///   - pattern: 路由模式
    ///   - flags: 路由标志位，默认为 .none
    ///   - priority: 优先级，默认为 0
    ///   - handler: 处理闭包
    public init(
        pattern: String,
        flags: RouteFlags = .none,
        priority: Int = 0,
        handler: @escaping @Sendable (RouteContext) -> Bool
    ) {
        self.pattern = pattern
        self.flags = flags
        self.priority = priority
        self.handler = handler
    }
}
