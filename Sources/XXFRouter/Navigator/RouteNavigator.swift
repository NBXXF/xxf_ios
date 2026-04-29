//
//  RouteNavigator.swift
//  XXFRouter
//
//  路由导航器，负责执行实际的视图控制器导航
//  Created by XXF on 2024
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 导航器协议

/// 路由导航器协议
@MainActor
public protocol RouteNavigator: AnyObject, Sendable {
    /// 执行导航
    /// - Parameters:
    ///   - viewController: 目标视图控制器
    ///   - context: 路由上下文
    ///   - options: 导航选项
    ///   - completion: 完成回调
    func navigate(
        to viewController: RouteViewController,
        context: RouteContext,
        options: RouteOptions,
        completion: (@Sendable (Bool) -> Void)?
    )

    /// 获取当前顶层视图控制器
    func topViewController() -> RouteViewController?

    /// 获取当前导航控制器
    func currentNavigationController() -> RouteNavigationController?
}

#if canImport(UIKit)
public extension RouteNavigator {
    /// 包装一个 rootViewController 成 NavigationController（用于 present / setRoot 等需要 nav 栈的场景）
    ///
    /// 默认实现返回 `XXFNavigationController`，它在系统 `UINavigationController` 之上额外支持：
    ///   - 作为 presented 根时从屏幕左边缘右滑 dismiss 整个模态（填补 iOS 原生缺失的手势）
    ///   - 接管 `interactivePopGestureRecognizer.delegate`，保证隐藏系统 NavBar 后栈内页面仍能右滑返回
    ///
    /// 若传入的 `rootViewController` 本身已经是 `UINavigationController`（或其子类），默认实现会直接返回它自己，
    /// 避免出现 nav 嵌套 nav 的异常栈结构；业务 override 本方法时也请遵循同样的约定。
    ///
    /// 业务若需改用其他 NavigationController 子类（例如自绘顶栏的 AppNavigationController），
    /// 实现自己的 `RouteNavigator` 时 override 本方法即可；也可以让自定义类继承 `XXFNavigationController`
    /// 后继续从默认实现受益。
    func makeNavigationController(rootViewController: RouteViewController) -> RouteNavigationController {
        // 已是 nav 直接返回，防止嵌套
        if let nav = rootViewController as? UINavigationController {
            return nav
        }
        return XXFNavigationController(rootViewController: rootViewController)
    }
}
#endif

// MARK: - 默认导航器实现

#if canImport(UIKit)

/// UIKit 默认导航器实现
public final class DefaultRouteNavigator: RouteNavigator, @unchecked Sendable {
    /// 共享实例
    public static let shared = DefaultRouteNavigator()

    /// 创建 NavigationController 的工厂闭包（可选，不进构造函数，按需后置替换）
    ///
    /// - 为 `nil`（默认）时：走协议扩展的 `makeNavigationController(rootViewController:)` 默认实现
    ///   （已是 nav 的 VC 直接返回，否则 `XXFNavigationController(rootViewController:)`）
    /// - 设置了闭包时：路由内部的 present / setRoot 改用本闭包产出 nav
    ///
    /// 业务可在 App 启动时替换，接入自己的 NavigationController 子类：
    /// ```swift
    /// DefaultRouteNavigator.shared.createNavigationViewControllerFactory = { root in
    ///     if let nav = root as? UINavigationController { return nav }
    ///     return AppNavigationController(rootViewController: root)
    /// }
    /// ```
    /// 自定义闭包也请保留「已是 nav 直接返回」约定，否则会出现 nav 嵌套 nav。
    public var createNavigationViewControllerFactory: ((RouteViewController) -> RouteNavigationController)?

    /// 初始化
    public init() {}

    /// 按优先级解析用于包装的 NavigationController：工厂 > 协议默认
    private func resolveNavigationController(for viewController: RouteViewController) -> RouteNavigationController {
        if let factory = createNavigationViewControllerFactory {
            return factory(viewController)
        }
        return makeNavigationController(rootViewController: viewController)
    }

    /// 执行导航
    public func navigate(
        to viewController: RouteViewController,
        context: RouteContext,
        options: RouteOptions,
        completion: (@Sendable (Bool) -> Void)?
    ) {
        Task { @MainActor in
            self.performNavigation(
                to: viewController,
                context: context,
                options: options,
                completion: completion
            )
        }
    }

    @MainActor
    private func performNavigation(
        to viewController: RouteViewController,
        context: RouteContext,
        options: RouteOptions,
        completion: (@Sendable (Bool) -> Void)?
    ) {
        // 处理导航前的模态视图关闭
        if options.dismissBeforeNavigation {
            if let presented = topViewController()?.presentedViewController {
                presented.dismiss(animated: options.animated) {
                    self.executeNavigation(
                        to: viewController,
                        context: context,
                        options: options,
                        completion: completion
                    )
                }
                return
            }
        }

        executeNavigation(
            to: viewController,
            context: context,
            options: options,
            completion: completion
        )
    }

    @MainActor
    private func executeNavigation(
        to viewController: RouteViewController,
        context: RouteContext,
        options: RouteOptions,
        completion: (@Sendable (Bool) -> Void)?
    ) {
        switch options.navigationType {
        case .push:
            executePush(
                to: viewController,
                context: context,
                options: options,
                completion: completion
            )

        case .present:
            executePresent(
                to: viewController,
                context: context,
                options: options,
                completion: completion
            )

        case .replace:
            executeReplace(
                to: viewController,
                context: context,
                options: options,
                completion: completion
            )

        case .replaceRoot(let transition):
            executeReplaceRoot(
                to: viewController,
                transition: transition,
                options: options,
                completion: completion
            )

        case .custom(let customNavigation):
            if let source = context.sourceViewController ?? topViewController() {
                customNavigation(source, viewController)
                completion?(true)
            } else {
                completion?(false)
            }
        }
    }

    @MainActor
    private func executePush(
        to viewController: RouteViewController,
        context: RouteContext,
        options: RouteOptions,
        completion: (@Sendable (Bool) -> Void)?
    ) {
        guard let navigationController = currentNavigationController() else {
            // 没有导航控制器，尝试present
            executePresent(
                to: viewController,
                context: context,
                options: options,
                completion: completion
            )
            return
        }

        // 设置是否隐藏底部TabBar
        viewController.hidesBottomBarWhenPushed = options.hidesBottomBarWhenPushed

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            options.completion?()
            completion?(true)
        }

        navigationController.pushViewController(viewController, animated: options.animated)

        CATransaction.commit()
    }

    @MainActor
    private func executePresent(
        to viewController: RouteViewController,
        context: RouteContext,
        options: RouteOptions,
        completion: (@Sendable (Bool) -> Void)?
    ) {
        guard let source = context.sourceViewController ?? topViewController() else {
            completion?(false)
            return
        }

        // 决定要 present 的视图控制器（是否包装 NavigationController）
        // 若 viewController 本身已经是 nav，跳过包装，避免 nav 嵌套 nav
        let vcToPresent: UIViewController
        if options.wrapInNavigationController, !(viewController is UINavigationController) {
            let nav = resolveNavigationController(for: viewController)
            nav.modalPresentationStyle = options.modalPresentationStyle
            nav.modalTransitionStyle = options.modalTransitionStyle
            vcToPresent = nav
        } else {
            viewController.modalPresentationStyle = options.modalPresentationStyle
            viewController.modalTransitionStyle = options.modalTransitionStyle
            vcToPresent = viewController
        }

        source.present(vcToPresent, animated: options.animated) {
            options.completion?()
            completion?(true)
        }
    }

    @MainActor
    private func executeReplace(
        to viewController: RouteViewController,
        context: RouteContext,
        options: RouteOptions,
        completion: (@Sendable (Bool) -> Void)?
    ) {
        guard let navigationController = currentNavigationController() else {
            completion?(false)
            return
        }

        var viewControllers = navigationController.viewControllers
        if !viewControllers.isEmpty {
            viewControllers.removeLast()
        }
        viewControllers.append(viewController)

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            options.completion?()
            completion?(true)
        }

        navigationController.setViewControllers(viewControllers, animated: options.animated)

        CATransaction.commit()
    }

    @MainActor
    private func executeReplaceRoot(
        to viewController: RouteViewController,
        transition: RootTransition,
        options: RouteOptions,
        completion: (@Sendable (Bool) -> Void)?
    ) {
        guard let window = Self.keyWindow() else {
            completion?(false)
            return
        }

        // 根据选项决定是否包装 NavigationController
        // 若 viewController 本身已经是 nav，跳过包装，避免 nav 嵌套 nav
        let newRootVC: UIViewController
        if options.wrapInNavigationController, !(viewController is UINavigationController) {
            newRootVC = resolveNavigationController(for: viewController)
        } else {
            newRootVC = viewController
        }

        // 根据过渡类型执行动画
        switch transition {
        case .none:
            window.rootViewController = newRootVC
            options.completion?()
            completion?(true)

        case .crossDissolve:
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = newRootVC
            } completion: { _ in
                options.completion?()
                completion?(true)
            }

        case .slideFromRight:
            UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromRight) {
                window.rootViewController = newRootVC
            } completion: { _ in
                options.completion?()
                completion?(true)
            }

        case .slideFromBottom:
            UIView.transition(with: window, duration: 0.3, options: .transitionCurlUp) {
                window.rootViewController = newRootVC
            } completion: { _ in
                options.completion?()
                completion?(true)
            }

        case .custom(let duration):
            UIView.transition(with: window, duration: duration, options: .transitionCrossDissolve) {
                window.rootViewController = newRootVC
            } completion: { _ in
                options.completion?()
                completion?(true)
            }
        }
    }

    /// 获取当前顶层视图控制器
    public func topViewController() -> RouteViewController? {
        return Self.findTopViewController()
    }

    /// 获取当前导航控制器
    public func currentNavigationController() -> RouteNavigationController? {
        return Self.findNavigationController()
    }

    // MARK: - 辅助方法

    /// 递归查找当前最顶层的 ViewController
    ///
    /// ⚠️ 防递归死循环说明：
    /// 当 presented 出来的 UINavigationController 的 viewControllers 被清空后（例如从栈中移除了所有 VC），
    /// `nav.visibleViewController` 会返回 nil。
    /// 如果此时直接递归 `findTopViewController(from: nil)`，会重新从 `keyWindow().rootViewController` 开始查找，
    /// 最终又走到同一个空的 NavigationController，形成无限递归，导致栈溢出 EXC_BAD_ACCESS。
    ///
    /// 因此对 UINavigationController 和 UITabBarController 的子 VC 做 nil 判断：
    /// - 子 VC 存在 → 继续递归
    /// - 子 VC 为 nil → 检查是否有 presentedViewController，有则递归它；否则返回容器自身，终止递归
    @MainActor
    private static func findTopViewController(
        from viewController: UIViewController? = nil
    ) -> UIViewController? {
        let rootVC = viewController ?? keyWindow()?.rootViewController

        if let nav = rootVC as? UINavigationController {
            if let visible = nav.visibleViewController {
                return findTopViewController(from: visible)
            }
            // nav 栈为空，尝试查找其 presented 的 VC，否则返回 nav 自身终止递归
            if let presented = nav.presentedViewController {
                return findTopViewController(from: presented)
            }
            return nav
        }

        if let tab = rootVC as? UITabBarController {
            if let selected = tab.selectedViewController {
                return findTopViewController(from: selected)
            }
            return tab
        }

        if let presented = rootVC?.presentedViewController {
            return findTopViewController(from: presented)
        }

        return rootVC
    }

    @MainActor
    private static func findNavigationController(
        from viewController: UIViewController? = nil
    ) -> UINavigationController? {
        let topVC = viewController ?? findTopViewController()

        if let nav = topVC as? UINavigationController {
            return nav
        }

        if let nav = topVC?.navigationController {
            return nav
        }

        if let tab = topVC as? UITabBarController,
           let nav = tab.selectedViewController as? UINavigationController {
            return nav
        }

        return nil
    }

    @MainActor
    private static func keyWindow() -> UIWindow? {
        if #available(iOS 15.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        }
    }
}

#elseif canImport(AppKit)

/// AppKit 默认导航器实现
public final class DefaultRouteNavigator: RouteNavigator, @unchecked Sendable {
    /// 共享实例
    public static let shared = DefaultRouteNavigator()

    /// 初始化
    public init() {}

    /// 执行导航
    public func navigate(
        to viewController: RouteViewController,
        context: RouteContext,
        options: RouteOptions,
        completion: (@Sendable (Bool) -> Void)?
    ) {
        Task { @MainActor in
            self.performNavigation(
                to: viewController,
                context: context,
                options: options,
                completion: completion
            )
        }
    }

    @MainActor
    private func performNavigation(
        to viewController: RouteViewController,
        context: RouteContext,
        options: RouteOptions,
        completion: (@Sendable (Bool) -> Void)?
    ) {
        switch options.navigationType {
        case .present:
            // macOS 使用 sheet 或新窗口
            if let source = context.sourceViewController ?? topViewController() {
                source.presentAsSheet(viewController)
                completion?(true)
            } else {
                completion?(false)
            }

        case .push, .replace:
            // macOS 没有原生的 push 概念，使用自定义实现
            if let source = context.sourceViewController ?? topViewController() {
                source.presentAsSheet(viewController)
                completion?(true)
            } else {
                completion?(false)
            }

        case .replaceRoot(let transition):
            // macOS 替换根视图控制器
            if let window = NSApplication.shared.keyWindow {
                switch transition {
                case .crossDissolve:
                    NSAnimationContext.runAnimationGroup({ context in
                        context.duration = 0.3
                        context.allowsImplicitAnimation = true
                        window.contentViewController = viewController
                    }, completionHandler: {
                        completion?(true)
                    })
                    return
                case .none:
                    window.contentViewController = viewController
                case .slideFromRight, .slideFromBottom, .custom:
                    // macOS 上使用淡入淡出作为默认动画
                    NSAnimationContext.runAnimationGroup({ context in
                        context.duration = 0.3
                        context.allowsImplicitAnimation = true
                        window.contentViewController = viewController
                    }, completionHandler: {
                        completion?(true)
                    })
                    return
                }
                completion?(true)
            } else {
                completion?(false)
            }

        case .custom(let customNavigation):
            if let source = context.sourceViewController ?? topViewController() {
                customNavigation(source, viewController)
                completion?(true)
            } else {
                completion?(false)
            }
        }

        options.completion?()
    }

    /// 获取当前顶层视图控制器
    public func topViewController() -> RouteViewController? {
        return NSApplication.shared.keyWindow?.contentViewController
    }

    /// 获取当前导航控制器
    public func currentNavigationController() -> RouteNavigationController? {
        return topViewController()
    }
}

#endif

// MARK: - 导航器扩展

public extension RouteNavigator {
    /// 简化的导航方法
    func navigate(
        to viewController: RouteViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        var options = RouteOptions.push
        options.animated = animated
        options.completion = completion

        let context = RouteContext(url: "")
        navigate(to: viewController, context: context, options: options, completion: nil)
    }

    /// Push导航
    func push(
        _ viewController: RouteViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        var options = RouteOptions.push
        options.animated = animated
        options.completion = completion

        let context = RouteContext(url: "")
        navigate(to: viewController, context: context, options: options, completion: nil)
    }

    /// Present导航
    func present(
        _ viewController: RouteViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        var options = RouteOptions.present
        options.animated = animated
        options.completion = completion

        let context = RouteContext(url: "")
        navigate(to: viewController, context: context, options: options, completion: nil)
    }
}
