//
//  Observable+Create.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//
import ObjectiveC
import RxCocoa
import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait, Element: BaseHttpResult {
    /// - Warning: 此方法已过时，请使用 `mapDataField` 方法。
    func mapHttpData() -> Single<Element.DataType> {
        return mapDataField()
    }

    func mapDataField() -> Single<Element.DataType> {
        return asObservable()
            .mapHttpData()
            .asSingle()
    }
}
