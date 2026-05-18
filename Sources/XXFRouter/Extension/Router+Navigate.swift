//
//  Router+Navigate.swift
//  XXFRouter
//
//  路由器扩展功能
//  提供简化的 navigate + pop API，以及辅助工具
//
//  Created by XXF on 2024
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - ═══════════════════════════════════════════════════════════════════

// MARK: 导航选项（Navigate Options）

// MARK: ═══════════════════════════════════════════════════════════════════

#if canImport(UIKit)

/// 导航选项
///
/// 统一控制所有前进导航行为的参数结构。
/// 通过不同的参数组合，实现 push、present、replace、replaceRoot 等各种导航方式。
///
/// ## 使用方式
///
/// ```swift
/// // 使用预设配置（推荐）
/// Router.shared.navigate(to: "app://settings", options: .pushHideTabBar)
/// Router.shared.navigate(to: "app://login", options: .presentFullScreen)
/// Router.shared.navigate(to: "app://main", options: .replaceRoot)
///
/// // 链式配置
/// let options = NavigateOptions(type: .present).style(.fullScreen).wrapNav(true)
/// Router.shared.navigate(to: "app://login", options: options)
/// ```
public struct NavigateOptions: Sendable {
    // MARK: - 导航类型

    /// 导航类型
    public enum NavigateType: Sendable {
        /// Push 导航（需要 NavigationController）
        case push
        /// Present 模态展示
        case present
        /// 替换当前页面（在导航栈中替换栈顶）
        case replace
        /// 替换根视图控制器（重置整个导航层级）
        case replaceRoot
    }

    // MARK: - 属性

    /// 导航类型，默认为 push
    public var navigateType: NavigateType
    /// 是否使用动画，默认为 true
    public var animated: Bool
    /// Push 时是否隐藏底部 TabBar，默认为 false
    public var hidesTabBar: Bool
    /// Present 时的展示样式，默认为 automatic
    public var presentationStyle: UIModalPresentationStyle
    /// 是否自动包装 NavigationController，默认为 false
    public var wrapInNav: Bool
    /// 替换根视图时的过渡动画，默认为淡入淡出
    public var rootTransition: RootTransition
    /// 导航前是否先 dismiss 当前模态视图，默认为 false
    public var dismissFirst: Bool

    // MARK: - 初始化

    public init(
        type: NavigateType = .push,
        animated: Bool = true,
        hidesTabBar: Bool = false,
        presentationStyle: UIModalPresentationStyle = .automatic,
        wrapInNav: Bool = false,
        rootTransition: RootTransition = .crossDissolve,
        dismissFirst: Bool = false
    ) {
        self.navigateType = type
        self.animated = animated
        self.hidesTabBar = hidesTabBar
        self.presentationStyle = presentationStyle
        self.wrapInNav = wrapInNav
        self.rootTransition = rootTransition
        self.dismissFirst = dismissFirst
    }

    // MARK: - 预设配置

    /// 默认 Push 导航
    public static let push = NavigateOptions(type: .push)

    /// Push 并隐藏 TabBar（适用于二级页面）
    public static let pushHideTabBar = NavigateOptions(type: .push, hidesTabBar: true)

    /// 默认 Present（Sheet 样式）
    public static let present = NavigateOptions(type: .present)

    /// 全屏 Present（带 NavigationController）
    public static let presentFullScreen = NavigateOptions(
        type: .present,
        presentationStyle: .fullScreen,
        wrapInNav: true
    )

    /// 全屏 Present（不带 NavigationController）
    public static let presentFullScreenNoNav = NavigateOptions(
        type: .present,
        presentationStyle: .fullScreen,
        wrapInNav: false
    )

    /// 替换当前页面
    public static let replace = NavigateOptions(type: .replace)

    /// 替换根视图控制器（淡入淡出）
    public static let replaceRoot = NavigateOptions(type: .replaceRoot)

    /// 替换根视图控制器（带 NavigationController）
    public static let replaceRootWithNav = NavigateOptions(
        type: .replaceRoot,
        wrapInNav: true
    )

    /// 替换根视图控制器（无动画）
    public static let replaceRootImmediate = NavigateOptions(
        type: .replaceRoot,
        rootTransition: .none
    )

    // MARK: - 链式配置方法

    public func type(_ type: NavigateType) -> NavigateOptions {
        var copy = self
        copy.navigateType = type
        return copy
    }

    public func animated(_ animated: Bool) -> NavigateOptions {
        var copy = self
        copy.animated = animated
        return copy
    }

    public func hideTabBar(_ hide: Bool) -> NavigateOptions {
        var copy = self
        copy.hidesTabBar = hide
        return copy
    }

    public func style(_ style: UIModalPresentationStyle) -> NavigateOptions {
        var copy = self
        copy.presentationStyle = style
        return copy
    }

    public func wrapNav(_ wrap: Bool) -> NavigateOptions {
        var copy = self
        copy.wrapInNav = wrap
        return copy
    }

    public func transition(_ transition: RootTransition) -> NavigateOptions {
        var copy = self
        copy.rootTransition = transition
        return copy
    }

    public func dismissFirst(_ dismiss: Bool) -> NavigateOptions {
        var copy = self
        copy.dismissFirst = dismiss
        return copy
    }

    // MARK: - 转换为内部 RouteOptions

    func toRouteOptions() -> RouteOptions {
        let navigationType: NavigationType
        switch self.navigateType {
        case .push:
            navigationType = .push
        case .present:
            navigationType = .present
        case .replace:
            navigationType = .replace
        case .replaceRoot:
            navigationType = .replaceRoot(transition: rootTransition)
        }

        return RouteOptions(
            navigationType: navigationType,
            animated: animated,
            modalPresentationStyle: presentationStyle,
            hidesBottomBarWhenPushed: hidesTabBar,
            wrapInNavigationController: wrapInNav,
            dismissBeforeNavigation: dismissFirst
        )
    }
}

// MARK: - ═══════════════════════════════════════════════════════════════════

// MARK: Router 简化 API

// MARK: ═══════════════════════════════════════════════════════════════════

public extension Router {
    // MARK: - Navigate（前进导航）

    /// 导航到指定路由
    ///
    /// 这是唯一的前进导航方法，通过 `NavigateOptions` 控制所有导航行为。
    ///
    /// ## 使用示例
    ///
    /// ```swift
    /// // Push 导航（默认）
    /// Router.shared.navigate(to: "app://profile/123")
    ///
    /// // 带参数导航
    /// Router.shared.navigate(to: "app://profile/123", parameters: ["preview": user])
    ///
    /// // 隐藏 TabBar
    /// Router.shared.navigate(to: "app://settings", options: .pushHideTabBar)
    ///
    /// // 全屏模态
    /// Router.shared.navigate(to: "app://login", options: .presentFullScreen)
    ///
    /// // 替换根视图
    /// Router.shared.navigate(to: "app://main", options: .replaceRootWithNav)
    /// ```
    ///
    /// - Parameters:
    ///   - url: 目标路由 URL
    ///   - parameters: 额外参数
    ///   - options: 导航选项，默认为 push
    ///   - from: 来源视图控制器（可选）
    ///   - completion: 完成回调
    @MainActor
    func navigate(
        to url: String,
        parameters: RouteParameters = [:],
        options: NavigateOptions = .push,
        from source: UIViewController? = nil,
        completion: (@Sendable (RouteResult) -> Void)? = nil
    ) {
        self.navigate(
            to: url,
            extraParameters: parameters,
            options: options.toRouteOptions(),
            from: source,
            completion: completion
        )
    }
}
#endif

// MARK: - ═══════════════════════════════════════════════════════════════════

// MARK: URL/String 扩展

// MARK: ═══════════════════════════════════════════════════════════════════

public extension URL {
    /// 转换为路由上下文
    func toRouteContext(
        extraParameters: RouteParameters = [:],
        flags: RouteFlags = .none
    ) -> RouteContext {
        var queryParams: RouteQueryItems = [:]

        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems
        {
            for item in queryItems {
                queryParams[item.name] = item.value ?? ""
            }
        }

        return RouteContext(
            url: absoluteString,
            queryParameters: queryParams,
            extraParameters: extraParameters,
            flags: flags
        )
    }
}

public extension String {
    /// 检查此URL字符串是否可以路由
    @MainActor
    var isRoutable: Bool {
        return Router.shared.canRoute(to: self)
    }

    /// 获取此URL对应的视图控制器（兼容接口，失败时返回 nil）
    @MainActor
    func toViewController(extraParameters: RouteParameters = [:]) -> RouteViewController? {
        return Router.shared.viewController(for: self, extraParameters: extraParameters)
    }

    /// 获取此URL对应的视图控制器，失败时抛出明确错误
    @MainActor
    func toViewControllerOrThrow(extraParameters: RouteParameters = [:]) throws -> RouteViewController {
        return try Router.shared.viewControllerOrThrow(for: self, extraParameters: extraParameters)
    }
}

// MARK: - ═══════════════════════════════════════════════════════════════════

// MARK: 路由 URL 构建器

// MARK: ═══════════════════════════════════════════════════════════════════

/// 路由URL构建器
public struct RouteURLBuilder: Sendable {
    private var scheme: String
    private var host: String
    private var pathComponents: [String]
    private var queryItems: [String: String]

    public init(scheme: String = "app", host: String = "") {
        self.scheme = scheme
        self.host = host
        self.pathComponents = []
        self.queryItems = [:]
    }

    public func path(_ component: String) -> RouteURLBuilder {
        var builder = self
        builder.pathComponents.append(component)
        return builder
    }

    public func query(_ key: String, _ value: String) -> RouteURLBuilder {
        var builder = self
        builder.queryItems[key] = value
        return builder
    }

    public func query(_ key: String, _ value: String?) -> RouteURLBuilder {
        guard let value = value else { return self }
        var builder = self
        builder.queryItems[key] = value
        return builder
    }

    public func build() -> String {
        var urlString = "\(scheme)://"

        if !host.isEmpty {
            urlString += host
        }

        if !pathComponents.isEmpty {
            let encodedComponents = pathComponents.map { component in
                component.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? component
            }
            urlString += "/" + encodedComponents.joined(separator: "/")
        }

        if !queryItems.isEmpty {
            let encodedQueryItems = queryItems.map { key, value in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            urlString += "?" + encodedQueryItems.joined(separator: "&")
        }

        return urlString
    }
}

/// 创建路由URL构建器
public func routeURL(scheme: String = "app", host: String = "") -> RouteURLBuilder {
    return RouteURLBuilder(scheme: scheme, host: host)
}

// MARK: - ═══════════════════════════════════════════════════════════════════

// MARK: 使用指南

// MARK: ═══════════════════════════════════════════════════════════════════

/*

 ╔══════════════════════════════════════════════════════════════════════════╗
 ║                           路由导航 API 指南                                ║
 ╠══════════════════════════════════════════════════════════════════════════╣
 ║ 核心方法：                                                                ║
 ║   • navigate(to:options:) - 所有前进导航                                  ║
 ║   • pop(options:)         - 所有后退导航                                  ║
 ╚══════════════════════════════════════════════════════════════════════════╝

 ┌─────────────────────────────────────────────────────────────────────────┐
 │ NavigateOptions 预设                                                     │
 ├─────────────────────────┬───────────────────────────────────────────────┤
 │ .push                   │ 默认 Push 导航                                 │
 │ .pushHideTabBar         │ Push 并隐藏 TabBar                             │
 │ .present                │ Sheet 样式 Present                             │
 │ .presentFullScreen      │ 全屏 Present（带 Nav）                          │
 │ .presentFullScreenNoNav │ 全屏 Present（无 Nav）                          │
 │ .replace                │ 替换当前页面                                    │
 │ .replaceRoot            │ 替换根视图（淡入淡出）                           │
 │ .replaceRootWithNav     │ 替换根视图（带 Nav）                            │
 │ .replaceRootImmediate   │ 替换根视图（无动画）                             │
 └─────────────────────────┴───────────────────────────────────────────────┘

 ┌─────────────────────────────────────────────────────────────────────────┐
 │ PopOptions 预设                                                          │
 ├─────────────────────────┬───────────────────────────────────────────────┤
 │ .smart                  │ 智能返回（优先 pop，不行则 dismiss）默认值      │
 │ .back                   │ 返回上一页                                     │
 │ .toRoot                 │ 返回到根页面                                   │
 │ .dismiss                │ 关闭模态视图                                    │
 │ .to(pattern:)           │ 返回到指定页面                                  │
 └─────────────────────────┴───────────────────────────────────────────────┘

 使用示例：

 // 在 ViewController 中
 navigate(to: AppRoutes.settings, options: .pushHideTabBar)
 navigate(to: AppRoutes.login, options: .presentFullScreen)
 navigate(to: AppRoutes.main, options: .replaceRootWithNav)
 pop()
 pop(options: .dismiss)

 // 使用 Router.shared
 Router.shared.navigate(to: "app://profile/123")
 Router.shared.pop(options: .toRoot)

 */
