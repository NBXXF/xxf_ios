//
//  Completable+Lifecycle.swift
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

public extension PrimitiveSequence where Trait == CompletableTrait, Element == Never {
    func bindUntilDeallocated<T: NSObject>(of object: T) -> Completable {
        return asObservable()
            .bindUntilDeallocated(of: object)
            .ignoreElements() // Completable 返回时需要变回 Completable
            .asCompletable()
    }

    #if canImport(UIKit)
        func bindLifecycle(
            of viewController: UIViewController,
            untilEvent: LifecycleEvent = .viewWillDisappear
        ) -> Completable {
            return asObservable()
                .bindLifecycle(of: viewController, untilEvent: untilEvent)
                .ignoreElements() // Completable 返回时需要变回 Completable
                .asCompletable()
        }

    #elseif canImport(AppKit)
        func bindLifecycle(
            of viewController: NSViewController,
            untilEvent: LifecycleEvent = .viewWillDisappear
        ) -> Completable {
            return asObservable()
                .bindLifecycle(of: viewController, untilEvent: untilEvent)
                .ignoreElements() // Completable 返回时需要变回 Completable
                .asCompletable()
        }
    #endif
}
