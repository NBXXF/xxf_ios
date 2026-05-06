//
//  ViewController+Ext.swift
//  xxf_ios
//
//  Created by xxf on 5/6.
//

#if canImport(UIKit)
import UIKit

public extension UIViewController {
    /// 关闭当前指定页面,兼容pop+dismiss
    func dismissOrPop(animated: Bool = true, completion: (() -> Void)? = nil) {
        popOrDismiss(animated: animated, completion: completion)
    }

    /// 关闭当前指定页面,兼容pop+dismiss
    func popOrDismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        let finish = CompletionBox(completion)

        // 已在关闭流程中时不重复触发关闭动作，避免重入导致的状态错乱。
        if isBeingDismissed || isMovingFromParent {
            finish.call()
            return
        }

        // self 上还有被 present 的页面时，先收敛到干净层级，再继续关闭 self。
        if presentedViewController != nil {
            dismiss(animated: animated) { [weak self] in
                guard let self else {
                    finish.call()
                    return
                }
                self.popOrDismiss(animated: animated) {
                    finish.call()
                }
            }
            return
        }

        // 1. 当前 VC 是被 present 出来的
        if presentingViewController != nil {
            dismiss(animated: animated) { finish.call() }
            return
        }

        // 2. 当前 VC 在 navigation 栈里，并且不是 root
        if let nav = navigationController,
           nav.viewControllers.count > 1,
           nav.topViewController === self
        {
            nav.popViewController(animated: animated)
            runCompletionAfterTransition(animated: animated) { finish.call() }
            return
        }

        // 3. 当前 VC 在 navigation 栈中间（不是 root，也不是 top）
        // 这种场景通常来自外部持有了 VC 引用并触发关闭。
        // 为避免留下 self 之后的无效流程页，这里会移除 self 以及其后续所有 VC。
        if let nav = navigationController,
           let index = nav.viewControllers.firstIndex(of: self),
           index > 0,
           index < nav.viewControllers.count - 1
        {
            let vcs = Array(nav.viewControllers.prefix(index))
            nav.setViewControllers(vcs, animated: false)
            finish.call()
            return
        }

        // 4. 当前 VC 是被 present 出来的 UINavigationController 的 rootVC
        if let nav = navigationController,
           nav.presentingViewController != nil,
           nav.viewControllers.first === self
        {
            nav.dismiss(animated: animated) { finish.call() }
            return
        }

        // 5. 兜底：不做事，避免误 pop root 导致异常
        finish.call()
    }

    private func runCompletionAfterTransition(animated: Bool, completion: @escaping () -> Void) {
        guard animated else {
            completion()
            return
        }
        if let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in completion() }
        } else {
            completion()
        }
    }
}

private final class CompletionBox {
    private var completion: (() -> Void)?

    init(_ completion: (() -> Void)?) {
        self.completion = completion
    }

    func call() {
        completion?()
        completion = nil
    }
}

#elseif canImport(AppKit)
import AppKit

public extension NSViewController {
    /// 关闭当前指定页面（AppKit 无导航栈，仅处理 dismiss 场景）
    func popOrDismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        _ = animated

        if let presenter = presentingViewController {
            presenter.dismiss(self)
            completion?()
            return
        }

        completion?()
    }
}
#endif
