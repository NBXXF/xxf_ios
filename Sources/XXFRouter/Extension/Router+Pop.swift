//
//  Router+Pop.swift
//  XXFRouter
//
//  路由器后退扩展功能
//  提供统一的 pop / dismiss API，以及 popTo / popSteps 辅助能力
//
//  Created by XXF on 2024
//

import Foundation

#if canImport(UIKit)
import UIKit

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

// MARK: Router 后退 API

// MARK: ═══════════════════════════════════════════════════════════════════

public extension Router {
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
    ///   - sourceViewController: 指定后退操作的来源控制器（可选）
    ///   - completion: 完成回调
    /// - Returns: 操作结果
    @MainActor
    @discardableResult
    func pop(
        options: PopOptions = .smart,
        from sourceViewController: RouteViewController? = nil,
        completion: (() -> Void)? = nil
    ) -> Any? {
        switch options.popType {
        case .smart:
            if let topVC = sourceViewController ?? navigator.topViewController(),
               topVC.presentingViewController != nil,
               topVC.navigationController == nil || topVC.navigationController?.viewControllers.count == 1
            {
                topVC.dismiss(animated: options.animated, completion: completion)
                return topVC
            }
            let smartPoppedVC = Self.resolveNavigationController(from: sourceViewController, navigator: navigator)?
                .popViewController(animated: options.animated)
            completion?()
            return smartPoppedVC

        case .back:
            let poppedVC = Self.resolveNavigationController(from: sourceViewController, navigator: navigator)?
                .popViewController(animated: options.animated)
            completion?()
            return poppedVC

        case .toRoot:
            Self.resolveNavigationController(from: sourceViewController, navigator: navigator)?
                .popToRootViewController(animated: options.animated)
            completion?()
            return true

        case .toPattern(let pattern):
            let success = self.popTo(
                pattern: pattern,
                from: sourceViewController,
                animated: options.animated,
                completion: completion
            )
            return success

        case .steps(let count):
            let result = self.popSteps(
                count,
                from: sourceViewController,
                animated: options.animated,
                completion: completion
            )
            return result

        case .dismiss:
            if let topVC = sourceViewController ?? navigator.topViewController() {
                var current: UIViewController? = topVC
                while let vc = current {
                    if vc.presentingViewController != nil {
                        vc.dismiss(animated: options.animated, completion: completion)
                        return true
                    }
                    current = vc.parent
                }
                topVC.dismiss(animated: options.animated, completion: completion)
            }
            return true
        }
    }

    // MARK: - 内部方法

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

    @MainActor
    private func findViewController(in nav: UINavigationController, pattern: String) -> UIViewController? {
        for vc in nav.viewControllers.reversed() {
            if matchesPattern(vc, pattern: pattern) {
                return vc
            }
        }
        return nil
    }

    @MainActor
    @discardableResult
    internal func popTo(
        pattern: String,
        from sourceViewController: RouteViewController? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        if let nav = Self.resolveNavigationController(from: sourceViewController, navigator: navigator),
           let targetVC = findViewController(in: nav, pattern: pattern)
        {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                completion?()
            }
            nav.popToViewController(targetVC, animated: animated)
            CATransaction.commit()
            return true
        }

        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }),
            let rootVC = window.rootViewController
        else {
            return false
        }

        var presentedChain: [UIViewController] = [rootVC]
        var current: UIViewController = rootVC
        while let presented = current.presentedViewController {
            presentedChain.append(presented)
            current = presented
        }

        for (index, vc) in presentedChain.enumerated() {
            let nav: UINavigationController?
            if let navVC = vc as? UINavigationController {
                nav = navVC
            } else if let tabVC = vc as? UITabBarController,
                      let selectedNav = tabVC.selectedViewController as? UINavigationController
            {
                nav = selectedNav
            } else {
                nav = vc.navigationController
            }

            guard let targetNav = nav,
                  let targetVC = findViewController(in: targetNav, pattern: pattern)
            else {
                continue
            }

            if index < presentedChain.count - 1 {
                let vcToDismissFrom = presentedChain[index]
                vcToDismissFrom.dismiss(animated: animated) {
                    targetNav.popToViewController(targetVC, animated: animated)
                    completion?()
                }
            } else {
                targetNav.popToViewController(targetVC, animated: animated)
                completion?()
            }
            return true
        }

        return false
    }

    @MainActor
    @discardableResult
    internal func popSteps(
        _ count: Int,
        from sourceViewController: RouteViewController? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        guard count >= 1,
              let nav = Self.resolveNavigationController(from: sourceViewController, navigator: navigator)
        else {
            return false
        }

        let vcs = nav.viewControllers
        guard vcs.count > 1 else { return false }

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

    @MainActor
    private static func resolveNavigationController(
        from sourceViewController: RouteViewController?,
        navigator: RouteNavigator
    ) -> RouteNavigationController? {
        if let nav = sourceViewController as? RouteNavigationController {
            return nav
        }
        if let nav = sourceViewController?.navigationController {
            return nav
        }
        return navigator.currentNavigationController()
    }
}



// MARK: - ═══════════════════════════════════════════════════════════════════

// MARK: 路由感知协议

// MARK: ═══════════════════════════════════════════════════════════════════

/// 视图控制器路由感知协议，用于支持 popTo 功能
public protocol RouteAwareViewController: AnyObject {
    var routeURL: String? { get }
}

#endif
