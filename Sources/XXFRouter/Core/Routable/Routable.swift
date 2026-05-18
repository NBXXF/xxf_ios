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

// MARK: - 可路由协议

/// 可路由协议，实现此协议的视图控制器可以通过路由系统进行导航
///
/// 使用示例：
/// ```swift
/// class ProfileViewController: UIViewController, Routable {
///     static var routePattern: String { "app://profile/<id>" }
///     static var routeFlags: RouteFlags { .requiresLogin }
///
///     required init(context: RouteContext) throws {
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
    /// - Throws: 业务可在此进行参数校验并抛出 RouteError，
    ///   例如 missingRequiredParameter / invalidParameterType / custom
    @MainActor init(context: RouteContext) throws
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
