//
//  Routable.swift
//  XXFRouter
//
//  可路由协议定义
//  Created by XXF on 2024
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

private struct RouteFactoryNilViewControllerError: Error, Sendable, CustomStringConvertible {
    let message: String
    var description: String { message }
}

// MARK: - 可路由协议

/// 可路由协议，实现此协议的视图控制器可以通过路由系统进行导航
///
/// 使用示例：
/// ```swift
/// class ProfileViewController: UIViewController, Routable {
///     static var routePattern: String { "app://profile/<id>" }
///     static var routeFlags: RouteFlags { .requiresLogin }
///
///     required init?(context: RouteContext) {
///         super.init(nibName: nil, bundle: nil)
///         // 从context中获取参数
///         if let userId = context.int(for: "id") {
///             self.userId = userId
///         }
///     }
/// }
/// ```
public protocol Routable: RouteViewController {
    /// 路由模式，支持路径参数
    /// 例如："app://user/<id>", "app://product/<category>/<id>"
    @MainActor static var routePattern: String { get }

    /// 路由标志位，用于拦截器判断
    @MainActor static var routeFlags: RouteFlags { get }

    /// 路由优先级，数值越大优先级越高
    /// 当多个路由匹配同一URL时，选择优先级最高的
    @MainActor static var routePriority: Int { get }

    /// 路由描述，用于调试和文档生成
    @MainActor static var routeDescription: String { get }

    /// 通过路由上下文创建实例
    /// - Parameter context: 路由上下文，包含URL参数等信息
    /// - Returns: 视图控制器实例，如果创建失败返回nil
    @MainActor init?(context: RouteContext)
}

// MARK: - 默认实现

public extension Routable {
    /// 默认无特殊标志
    @MainActor static var routeFlags: RouteFlags { .none }

    /// 默认优先级为0
    @MainActor static var routePriority: Int { 0 }

    /// 默认描述为类名
    @MainActor static var routeDescription: String { String(describing: Self.self) }
}

// MARK: - 路由工厂协议

/// 路由工厂协议，用于自定义视图控制器的创建逻辑
public protocol RouteFactory: Sendable {
    /// 路由模式
    var pattern: String { get }

    /// 路由标志位
    var flags: RouteFlags { get }

    /// 优先级
    var priority: Int { get }

    /// 创建视图控制器（必须在主线程调用）
    /// - Parameter context: 路由上下文
    /// - Returns: 视图控制器实例
    /// - Throws: 业务可在此进行参数校验并抛出 RouteError，
    ///   例如 missingRequiredParameter / invalidParameterType / custom
    @MainActor func createViewController(with context: RouteContext) throws -> RouteViewController
}

// MARK: - 闭包路由工厂

/// 基于闭包的路由工厂实现
public final class ClosureRouteFactory: RouteFactory, @unchecked Sendable {
    public let pattern: String
    public let flags: RouteFlags
    public let priority: Int

    private let factory: @MainActor @Sendable (RouteContext) throws -> RouteViewController

    /// 创建闭包路由工厂
    /// - Parameters:
    ///   - pattern: 路由模式
    ///   - flags: 路由标志位
    ///   - priority: 优先级
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

    @MainActor
    public func createViewController(with context: RouteContext) throws -> RouteViewController {
        return try factory(context)
    }
}

// MARK: - 类型路由工厂

/// 基于类型的路由工厂实现
public final class TypeRouteFactory<T: Routable>: RouteFactory, @unchecked Sendable {
    public let pattern: String
    public let flags: RouteFlags
    public let priority: Int

    private let type: T.Type

    /// 创建类型路由工厂
    /// - Parameter type: Routable类型
    @MainActor
    public init(type: T.Type) {
        self.type = type
        self.pattern = type.routePattern
        self.flags = type.routeFlags
        self.priority = type.routePriority
    }

    @MainActor
    public func createViewController(with context: RouteContext) throws -> RouteViewController {
        guard let viewController = type.init(context: context) else {
            throw RouteError.routeFactoryThrown(
                url: context.url,
                underlyingError: RouteFactoryNilViewControllerError(
                    message: "Routable initializer returned nil for \(String(describing: type))"
                )
            )
        }
        return viewController
    }
}

// MARK: - 路由处理器协议

/// 路由处理器协议，用于处理特定的URL但不创建视图控制器
/// 适用于：打开外部链接、执行特定操作等场景
public protocol RouteHandler: Sendable {
    /// 路由模式
    var pattern: String { get }

    /// 路由标志位
    var flags: RouteFlags { get }

    /// 优先级
    var priority: Int { get }

    /// 处理路由
    /// - Parameter context: 路由上下文
    /// - Returns: 是否处理成功
    func handle(context: RouteContext) -> Bool
}

// MARK: - 闭包路由处理器

/// 基于闭包的路由处理器实现
public final class ClosureRouteHandler: RouteHandler, @unchecked Sendable {
    public let pattern: String
    public let flags: RouteFlags
    public let priority: Int

    private let handler: @Sendable (RouteContext) -> Bool

    /// 创建闭包路由处理器
    /// - Parameters:
    ///   - pattern: 路由模式
    ///   - flags: 路由标志位
    ///   - priority: 优先级
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

    public func handle(context: RouteContext) -> Bool {
        return handler(context)
    }
}

// MARK: - 类型擦除路由工厂

/// 类型擦除的路由工厂，用于支持 [any Routable.Type] 批量注册
///
/// 由于 Swift 泛型系统限制，无法直接从 `any Routable.Type` 创建 `TypeRouteFactory<T>`，
/// 因此使用此类型擦除包装器来解决这个问题。
public final class AnyRoutableFactory: RouteFactory, @unchecked Sendable {
    public let pattern: String
    public let flags: RouteFlags
    public let priority: Int

    /// 类型擦除的创建闭包
    private let createBlock: @MainActor @Sendable (RouteContext) -> RouteViewController?

    /// 创建类型擦除工厂
    /// - Parameter type: 任意 Routable 类型
    @MainActor
    public init(type: any Routable.Type) {
        self.pattern = type.routePattern
        self.flags = type.routeFlags
        self.priority = type.routePriority
        // 捕获类型并存储创建闭包
        self.createBlock = { context in
            type.init(context: context)
        }
    }

    @MainActor
    public func createViewController(with context: RouteContext) throws -> RouteViewController {
        guard let viewController = createBlock(context) else {
            throw RouteError.routeFactoryThrown(
                url: context.url,
                underlyingError: RouteFactoryNilViewControllerError(
                    message: "Routable initializer returned nil for erased type"
                )
            )
        }
        return viewController
    }
}

// MARK: - 批量注册配置类型

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
