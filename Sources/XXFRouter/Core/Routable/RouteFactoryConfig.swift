//
//  RouteFactoryConfig.swift
//  XXFRouter
//
//  路由工厂配置
//  Created by XXF on 2024
//

/// 路由工厂配置，用于批量注册闭包工厂
///
/// 使用示例：
/// ```swift
/// let configs: [RouteFactoryConfig] = [
///     RouteFactoryConfig(pattern: "app://home") { _ in HomeVC() },
///     RouteFactoryConfig(pattern: "app://profile/<userId>", flags: .requiresLogin) { ctx in
///         ProfileVC(userId: ctx.string(for: "userId") ?? "")
///     }
/// ]
/// router.register(factories: configs)
/// ```
public struct RouteFactoryConfig: Sendable {
    /// 路由模式
    public let pattern: String
    /// 路由标志位
    public let flags: RouteFlags
    /// 优先级
    public let priority: Int
    /// 工厂闭包。业务可在此进行参数校验并抛出 RouteError，
    /// 例如 missingRequiredParameter / invalidParameterType / custom
    public let factory: @MainActor @Sendable (RouteContext) throws -> RouteViewController

    /// 创建路由工厂配置
    /// - Parameters:
    ///   - pattern: 路由模式
    ///   - flags: 路由标志位，默认为 .none
    ///   - priority: 优先级，默认为 0
    ///   - factory: 创建视图控制器的闭包。
    ///     业务可在此进行参数校验并抛出 RouteError，
    ///     例如 missingRequiredParameter / invalidParameterType / custom
    public init(
        pattern: String,
        flags: RouteFlags = .none,
        priority: Int = 0,
        factory: @escaping @MainActor @Sendable (RouteContext) throws -> RouteViewController
    ) {
        self.pattern = pattern
        self.flags = flags
        self.priority = priority
        self.factory = factory
    }
}
