//
//  Single+Lifecycle.swift
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

public extension PrimitiveSequence where Trait == SingleTrait {
    func bindUntilDeallocated<T: NSObject>(of object: T) -> Single<Element> {
        return asObservable()
            .bindUntilDeallocated(of: object)
            .asSingle()
    }

    #if canImport(UIKit)
        func bindLifecycle(
            of viewController: UIViewController,
            untilEvent: LifecycleEvent = .viewWillDisappear
        ) -> Single<Element> {
            return asObservable()
                .bindLifecycle(of: viewController, untilEvent: untilEvent)
                .asSingle()
        }

    #elseif canImport(AppKit)
        func bindLifecycle(
            of viewController: NSViewController,
            untilEvent: LifecycleEvent = .viewWillDisappear
        ) -> Single<Element> {
            return asObservable()
                .bindLifecycle(of: viewController, untilEvent: untilEvent)
                .asSingle()
        }
    #endif
}
