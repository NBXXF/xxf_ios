//
//  Observable+Create.swift
//  xxf_ios
//
//  Created by xxf on /5/26.
//
import ObjectiveC
import RxCocoa
import RxSwift

public extension PrimitiveSequence where Trait == MaybeTrait {
    func bindUntilDeallocated<T: NSObject>(of object: T) -> Maybe<Element> {
        return asObservable()
            .take(until: object.rx.deallocated)
            .asMaybe()
    }
}
