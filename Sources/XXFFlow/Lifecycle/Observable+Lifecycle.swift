//
//  Observable+Lifecycle.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//

import ObjectiveC
import RxCocoa
import RxSwift

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

public extension ObservableType {
    /// 绑定生命周期，直到对象释放
    func bindUntilDeallocated<T: NSObject>(of object: T) -> Observable<Element> {
        return take(until: object.rx.deallocated)
    }

    #if canImport(UIKit)
        /// 绑定生命周期到 UIViewController 生命周期事件（UIKit）
        func bindLifecycle(
            of viewController: UIViewController,
            untilEvent: LifecycleEvent = .viewDeallocated
        ) -> Observable<Element> {
            if untilEvent == .viewDeallocated {
                return bindUntilDeallocated(of: viewController)
            } else {
                return take(until: viewController.rx.methodInvoked(untilEvent.selector!))
            }
        }

    #elseif canImport(AppKit)
        /// 绑定生命周期到 NSViewController 生命周期事件（AppKit）
        func bindLifecycle(
            of viewController: NSViewController,
            untilEvent: LifecycleEvent = .viewDeallocated
        ) -> Observable<Element> {
            if untilEvent == .viewDeallocated {
                return bindUntilDeallocated(of: viewController)
            } else {
                return take(until: viewController.rx.methodInvoked(untilEvent.selector!))
            }
        }
    #endif
}
