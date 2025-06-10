//
//  Observable+Create.swift
//  xxf_ios
//
//  Created by xxf on /5/26.
//
import ObjectiveC
import RxCocoa
import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {
    func bindUntilDeallocated<T: NSObject>(of object: T) -> Single<Element> {
        return asObservable()
            .take(until: object.rx.deallocated)
            .asSingle()
    }
}
