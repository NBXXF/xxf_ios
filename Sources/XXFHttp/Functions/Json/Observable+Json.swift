//
//  Observable+Json.swift
//  fileaimanager
//
//  Created by xxf on 2024/9/2.
//

import Foundation
import RxSwift
import XXFJson
import Moya

public extension ObservableType where Element == Response {
    /// 和官方moya一摸一样,只是替换decoder默认值为LoggingJSONDecoder, 会记录错误日志
    func mapHttpResponse<D: Decodable>(
        _ type: D.Type,
        atKeyPath keyPath: String? = nil,
        using decoder: Foundation.JSONDecoder = LoggingJSONDecoder(),
        failsOnEmptyData: Bool = true
    ) -> Observable<D> {
        return self.map(type, atKeyPath: keyPath, using: decoder, failsOnEmptyData: failsOnEmptyData)
    }
}
