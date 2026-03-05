//
//  Observable+Create.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//
import Foundation
import ObjectiveC
import RxCocoa
import RxSwift

public extension Observable where Element: BaseHttpResult {
    /// - Warning: 此方法已过时，请使用 `mapDataField` 方法。
    func mapHttpData() -> Observable<Element.DataType> {
        return mapDataField()
    }

    func mapDataField() -> Observable<Element.DataType> {
        return flatMap { result -> Observable<Element.DataType> in
            guard result.isSuccess() else {
                return .error(ResponseError(
                    statusCode: result.code,
                    message: result.msg ?? "接口未知错误"
                ))
            }
            guard let data = result.data else {
                return .error(ResponseError(
                    statusCode: result.code,
                    message: "接口data字段为空"
                ))
            }
            return .just(data)
        }
    }
}
