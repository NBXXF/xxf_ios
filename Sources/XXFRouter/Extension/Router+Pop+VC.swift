//
//  Router+Pop+VC.swift
//  xxf_ios
//
//  Created by xxf
//

// MARK: UIViewController 后退快捷入口

#if canImport(UIKit)
import UIKit

public extension UIViewController {
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
        return Router.shared.pop(options: options, from: self, completion: completion)
    }
}
#endif
