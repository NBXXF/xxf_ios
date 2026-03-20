//
//  Router+Extension.swift
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

// MARK: 后退选项（Pop Options）

// MARK: ═══════════════════════════════════════════════════════════════════

/// 后退选项
///
/// 统一控制所有后退导航行为的参数结构。
///
/// ## 使用方式
///
/// ```swift
/// Router.shared.pop()                              // 返回上一页
/// Router.shared.pop(options: .toRoot)              // 返回根页面
/// Router.shared.pop(options: .dismiss)             // 关闭模态
/// Router.shared.pop(options: .to(pattern: "app://feed"))  // 返回指定页面
/// ```
public struct PopOptions: Sendable {
    /// 后退类型
    public enum PopType: Sendable {
        /// 智能返回（如果是 present 出来的则 dismiss，否则 pop）
        case smart
        /// 返回上一页
        case back
        /// 返回到根页面
        case toRoot
        /// 返回到指定页面
        case toPattern(String)
        /// 返回指定步数（例如 .steps(2) 表示返回两步）
        case steps(Int)
        /// 关闭模态视图
        case dismiss
    }

    public var popType: PopType
    public var animated: Bool

    public init(type: PopType = .smart, animated: Bool = true) {
        self.popType = type
        self.animated = animated
    }

    // MARK: - 预设配置

    /// 智能返回（默认：如果是 present 出来的则 dismiss，否则 pop）
    public static let smart = PopOptions(type: .smart)
    /// 返回上一页
    public static let back = PopOptions(type: .back)
    /// 返回到根页面
    public static let toRoot = PopOptions(type: .toRoot)
    /// 关闭模态视图
    public static let dismiss = PopOptions(type: .dismiss)
    /// 智能返回（无动画）
    public static let smartImmediate = PopOptions(type: .smart, animated: false)
    /// 返回上一页（无动画）
    public static let backImmediate = PopOptions(type: .back, animated: false)
    /// 返回根页面（无动画）
    public static let toRootImmediate = PopOptions(type: .toRoot, animated: false)
    /// 关闭模态（无动画）
    public static let dismissImmediate = PopOptions(type: .dismiss, animated: false)

    /// 返回到指定页面
    public static func to(pattern: String) -> PopOptions {
        return PopOptions(type: .toPattern(pattern))
    }

    /// 返回指定步数
    public static func steps(_ count: Int) -> PopOptions {
        return PopOptions(type: .steps(count))
    }

    public func animated(_ animated: Bool) -> PopOptions {
        var copy = self
        copy.animated = animated
        return copy
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

    // MARK: - Pop（后退导航）

    /// 后退导航
    ///
    /// 这是唯一的后退导航方法，通过 `PopOptions` 控制所有后退行为。
    ///
    /// ## 使用示例
    ///
    /// ```swift
    /// Router.shared.pop()                              // 智能返回（自动判断 pop 或 dismiss）
    /// Router.shared.pop(options: .back)               // 强制 pop
    /// Router.shared.pop(options: .toRoot)              // 返回根页面
    /// Router.shared.pop(options: .dismiss)             // 关闭模态
    /// Router.shared.pop(options: .to(pattern: "app://feed"))  // 返回指定页面
    /// Router.shared.pop(options: .steps(2))            // 返回两步
    /// ```
    ///
    /// - Parameters:
    ///   - options: 后退选项，默认为返回上一页
    ///   - completion: 完成回调
    /// - Returns: 操作结果
    @MainActor
    @discardableResult
    func pop(
        options: PopOptions = .smart,
        completion: (() -> Void)? = nil
    ) -> Any? {
        switch options.popType {
        case .smart:
            // 智能判断：如果当前页面是 present 出来的（没有导航控制器，或者是导航栈的根控制器），则 dismiss；否则 pop
            if let topVC = navigator.topViewController(),
               topVC.presentingViewController != nil,
               topVC.navigationController == nil || topVC.navigationController?.viewControllers.count == 1
            {
                topVC.dismiss(animated: options.animated, completion: completion)
                return topVC
            }
            let smartPoppedVC = navigator.currentNavigationController()?.popViewController(animated: options.animated)
            completion?()
            return smartPoppedVC

        case .back:
            let poppedVC = navigator.currentNavigationController()?.popViewController(animated: options.animated)
            completion?()
            return poppedVC

        case .toRoot:
            navigator.currentNavigationController()?.popToRootViewController(animated: options.animated)
            completion?()
            return true

        case .toPattern(let pattern):
            let success = self.popTo(pattern: pattern, animated: options.animated, completion: completion)
            return success

        case .steps(let count):
            let result = self.popSteps(count, animated: options.animated, completion: completion)
            return result

        case .dismiss:
            // 找到被 present 出来的最顶层控制器（可能是 nav 或者 VC 自身），让 presentingVC 来 dismiss
            if let topVC = navigator.topViewController() {
                // 沿 parent 链向上找到被 present 出来的控制器
                var current: UIViewController? = topVC
                while let vc = current {
                    if vc.presentingViewController != nil {
                        vc.dismiss(animated: options.animated, completion: completion)
                        return true
                    }
                    current = vc.parent
                }
                // fallback
                topVC.dismiss(animated: options.animated, completion: completion)
            }
            return true
        }
    }

    // MARK: - 内部方法

    /// 判断视图控制器是否匹配指定路由模式
    @MainActor
    private func matchesPattern(_ vc: UIViewController, pattern: String) -> Bool {
        if let routable = vc as? Routable, type(of: routable).routePattern == pattern {
            return true
        }
        if let routeURL = (vc as? RouteAwareViewController)?.routeURL, routeURL == pattern {
            return true
        }
        return false
    }

    /// 在导航控制器栈中查找匹配指定路由模式的视图控制器
    @MainActor
    private func findViewController(in nav: UINavigationController, pattern: String) -> UIViewController? {
        for vc in nav.viewControllers.reversed() {
            if matchesPattern(vc, pattern: pattern) {
                return vc
            }
        }
        return nil
    }

    /// Pop 到指定路由模式对应的页面
    ///
    /// 支持跨 modal 层级查找：如果目标路由不在当前导航栈中，
    /// 会依次 dismiss 模态视图并在底层导航栈中查找目标。
    ///
    /// ## 场景示例
    ///
    /// ```
    /// TabBar -> Nav [A, B] -> present Nav [C, D]
    /// popTo("A") → dismiss [C, D] 的 modal，然后 pop 到 A
    /// ```
    ///
    /// - Parameters:
    ///   - pattern: 目标路由模式
    ///   - animated: 是否使用动画
    ///   - completion: 完成回调
    /// - Returns: 是否成功找到并导航到目标
    @MainActor
    @discardableResult
    internal func popTo(pattern: String, animated: Bool = true, completion: (() -> Void)? = nil) -> Bool {
        // 1. 先在当前导航控制器栈中查找
        if let nav = navigator.currentNavigationController(),
           let targetVC = findViewController(in: nav, pattern: pattern) {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                completion?()
            }
            nav.popToViewController(targetVC, animated: animated)
            CATransaction.commit()
            return true
        }

        // 2. 当前栈找不到，遍历整个 presented 链，逐层查找
        //    收集从 rootViewController 到最顶层的所有 presented VC 链
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }),
            let rootVC = window.rootViewController else {
            return false
        }

        // 构建 presented 链：[rootVC, presented1, presented2, ...]
        var presentedChain: [UIViewController] = [rootVC]
        var current: UIViewController = rootVC
        while let presented = current.presentedViewController {
            presentedChain.append(presented)
            current = presented
        }

        // 从底层向上查找目标路由所在的导航控制器
        for (index, vc) in presentedChain.enumerated() {
            // 获取该层级的导航控制器
            let nav: UINavigationController?
            if let navVC = vc as? UINavigationController {
                nav = navVC
            } else if let tabVC = vc as? UITabBarController,
                      let selectedNav = tabVC.selectedViewController as? UINavigationController {
                nav = selectedNav
            } else {
                nav = vc.navigationController
            }

            guard let targetNav = nav,
                  let targetVC = findViewController(in: targetNav, pattern: pattern) else {
                continue
            }

            // 找到了目标！需要 dismiss 掉该层级之上的所有 modal，再 pop
            if index < presentedChain.count - 1 {
                // 该层级有 presented 的 VC，需要先 dismiss
                // dismiss 由 presenting 侧调用，会连带 dismiss 其上所有 presented
                let vcToDismissFrom = presentedChain[index]
                vcToDismissFrom.dismiss(animated: animated) {
                    targetNav.popToViewController(targetVC, animated: animated)
                    completion?()
                }
            } else {
                // 目标就在当前层级（理论上不会走到这里，因为第 1 步已经处理）
                targetNav.popToViewController(targetVC, animated: animated)
                completion?()
            }
            return true
        }

        return false
    }

    /// Pop 指定步数
    ///
    /// 从当前导航栈中往回退 N 步。如果步数超过栈的深度，则回到根页面。
    ///
    /// ## 场景示例
    ///
    /// ```
    /// Nav [A, B, C, D] → popSteps(2) → Nav [A, B]
    /// Nav [A, B, C, D] → popSteps(10) → Nav [A]（超出范围则回到根）
    /// ```
    ///
    /// - Parameters:
    ///   - count: 返回步数，必须 >= 1
    ///   - animated: 是否使用动画
    ///   - completion: 完成回调
    /// - Returns: 是否成功
    @MainActor
    @discardableResult
    internal func popSteps(_ count: Int, animated: Bool = true, completion: (() -> Void)? = nil) -> Bool {
        guard count >= 1,
              let nav = navigator.currentNavigationController() else {
            return false
        }

        let vcs = nav.viewControllers
        guard vcs.count > 1 else { return false }

        // 计算目标索引：当前栈顶往回 count 步，最小为 0（根页面）
        let targetIndex = max(vcs.count - 1 - count, 0)
        let targetVC = vcs[targetIndex]

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        nav.popToViewController(targetVC, animated: animated)
        CATransaction.commit()
        return true
    }
}

// MARK: ═══════════════════════════════════════════════════════════════════

public extension UIViewController {
    /// 导航到指定路由
    ///
    /// ```swift
    /// navigate(to: AppRoutes.settings, options: .pushHideTabBar)
    /// navigate(to: AppRoutes.login, options: .presentFullScreen)
    /// ```
    func navigate(
        to url: String,
        parameters: RouteParameters = [:],
        options: NavigateOptions = .push,
        completion: (@Sendable (RouteResult) -> Void)? = nil
    ) {
        Router.shared.navigate(
            to: url,
            parameters: parameters,
            options: options,
            from: self,
            completion: completion
        )
    }

    /// 后退导航
    ///
    /// ```swift
    /// pop()                    // 返回上一页
    /// pop(options: .toRoot)    // 返回根页面
    /// pop(options: .dismiss)   // 关闭模态
    /// ```
    @discardableResult
    func pop(
        options: PopOptions = .smart,
        completion: (() -> Void)? = nil
    ) -> Any? {
        return Router.shared.pop(options: options, completion: completion)
    }
}

// MARK: - 路由感知协议

/// 视图控制器路由感知协议，用于支持 popTo 功能
public protocol RouteAwareViewController: AnyObject {
    var routeURL: String? { get }
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

    /// 获取此URL对应的视图控制器
    @MainActor
    func toViewController(extraParameters: RouteParameters = [:]) -> RouteViewController? {
        return Router.shared.viewController(for: self, extraParameters: extraParameters)
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
