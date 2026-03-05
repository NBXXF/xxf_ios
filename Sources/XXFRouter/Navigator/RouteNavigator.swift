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

// MARK: - 默认导航器实现

#if canImport(UIKit)

/// UIKit 默认导航器实现
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

        viewController.modalPresentationStyle = options.modalPresentationStyle
        viewController.modalTransitionStyle = options.modalTransitionStyle

        source.present(viewController, animated: options.animated) {
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

    /// 获取当前顶层视图控制器
    public func topViewController() -> RouteViewController? {
        return Self.findTopViewController()
    }

    /// 获取当前导航控制器
    public func currentNavigationController() -> RouteNavigationController? {
        return Self.findNavigationController()
    }

    // MARK: - 辅助方法

    @MainActor
    private static func findTopViewController(
        from viewController: UIViewController? = nil
    ) -> UIViewController? {
        let rootVC = viewController ?? keyWindow()?.rootViewController

        if let nav = rootVC as? UINavigationController {
            return findTopViewController(from: nav.visibleViewController)
        }

        if let tab = rootVC as? UITabBarController {
            return findTopViewController(from: tab.selectedViewController)
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
