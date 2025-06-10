//
//  Observable+Create.swift
//  xxf_ios
//
//  Created by xxf on /5/26.
//
import ObjectiveC
import RxCocoa
import RxSwift

public extension PrimitiveSequence where Trait == CompletableTrait, Element == Never {
    func bindUntilDeallocated<T: NSObject>(of object: T) -> Completable {
        return asObservable()
            .take(until: object.rx.deallocated)
            .ignoreElements() // Completable 返回时需要变回 Completable
            .asCompletable()
    }
}
