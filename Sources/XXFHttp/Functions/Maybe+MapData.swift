//
//  Observable+Create.swift
//  xxf_ios
//
//  Created by xxf on /5/26.
//
import ObjectiveC
import RxCocoa
import RxSwift

extension PrimitiveSequence where Trait == MaybeTrait, Element: BaseHttpResult {
    /// 直接返回对应的data字段
    func mapHttpData() -> Maybe<Element.DataType> {
        return asObservable()
            .mapHttpData()
            .asMaybe()
    }
}
