//
//  Router+Navigate+VC.swift
//  xxf_ios
//
//  Created by xxf
//

// MARK: UIViewController 导航快捷入口

#if canImport(UIKit)
import UIKit

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
}
#endif
