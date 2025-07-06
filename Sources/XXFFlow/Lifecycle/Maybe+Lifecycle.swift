//
//  Maybe+Lifecycle.swift
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

public extension PrimitiveSequence where Trait == MaybeTrait {
    func bindUntilDeallocated<T: NSObject>(of object: T) -> Maybe<Element> {
        return asObservable()
            .bindUntilDeallocated(of: object)
            .asMaybe()
    }

    #if canImport(UIKit)
        func bindLifecycle(
            of viewController: UIViewController,
            untilEvent: LifecycleEvent = .viewWillDisappear
        ) -> Maybe<Element> {
            return asObservable()
                .bindLifecycle(of: viewController, untilEvent: untilEvent)
                .asMaybe()
        }

    #elseif canImport(AppKit)
        func bindLifecycle(
            of viewController: NSViewController,
            untilEvent: LifecycleEvent = .viewWillDisappear
        ) -> Maybe<Element> {
            return asObservable()
                .bindLifecycle(of: viewController, untilEvent: untilEvent)
                .asMaybe()
        }
    #endif
}
