//
//  Observable+Create.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//
import ObjectiveC
import RxCocoa
import RxSwift

public extension PrimitiveSequence where Trait == MaybeTrait, Element: BaseHttpResult {
    /// - Warning: 此方法已过时，请使用 `mapDataField` 方法。
    func mapHttpData() -> Maybe<Element.DataType> {
        return mapDataField()
    }

    /// 直接返回对应的data字段
    func mapDataField() -> Maybe<Element.DataType> {
        return asObservable()
            .mapHttpData()
            .asMaybe()
    }
}
