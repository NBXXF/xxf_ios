//
//  Observable+Create.swift
//  xxf_ios
//
//  Created by xxf on /5/26.
//
import ObjectiveC
import RxCocoa
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait, Element: BaseHttpResult {
    func mapHttpData() -> Single<Element.DataType> {
        return asObservable()
            .mapHttpData()
            .asSingle()
    }
}
