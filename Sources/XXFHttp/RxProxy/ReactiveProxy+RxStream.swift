//
//  ReactiveProxy+RxStream.swift
//  xxf_ios
//  增加rx代理,主要作用便是拦截
//  Created by xxf on 8/23.
//

import Alamofire
import Foundation
import Moya
import RxSwift

public extension ReactiveProxy where Base: ReactiveCompatible, Base.Target: Sendable {
    /// Data 流
    func requestStream(_ token: Base.Target,
                       callbackQueue: DispatchQueue? = .none) -> Observable<Data>
    {
        let observable: Observable<Data> = base.rx.requestStream(token, callbackQueue: callbackQueue)

        // 如果 base 是 HttpMoyaProvider 并且有拦截器
        if let httpProvider = base as? HttpMoyaProvider<Base.Target>,
           let interceptor = httpProvider.callAdapter
        {
            return interceptor.adapt(observable, target: token)
        }

        // 否则直接返回原始请求
        return observable
    }

    /// UTF8 String 流
    func requestStreamString(_ token: Base.Target,
                             callbackQueue: DispatchQueue? = .none) -> Observable<String>
    {
        let observable: Observable<String> = base.rx.requestStreamString(token, callbackQueue: callbackQueue)

        // 如果 base 是 HttpMoyaProvider 并且有拦截器
        if let httpProvider = base as? HttpMoyaProvider<Base.Target>,
           let interceptor = httpProvider.callAdapter
        {
            return interceptor.adapt(observable, target: token)
        }

        // 否则直接返回原始请求
        return observable
    }

    /// Decodable 流
    func requestStreamDecodable<T: Decodable & Sendable>(
        _ token: Base.Target,
        type: T.Type = T.self,
        callbackQueue: DispatchQueue? = .none,
        decoder: any Alamofire.DataDecoder = JSONDecoder(),
        preprocessor: any DataPreprocessor = PassthroughPreprocessor()
    ) -> Observable<T> {
        let observable: Observable<T> = base.rx.requestStreamDecodable(
            token,
            type: type,
            callbackQueue: callbackQueue,
            decoder: decoder,
            preprocessor: preprocessor
        )

        // 如果 base 是 HttpMoyaProvider 并且有拦截器
        if let httpProvider = base as? HttpMoyaProvider<Base.Target>,
           let interceptor = httpProvider.callAdapter
        {
            return interceptor.adapt(observable, target: token)
        }

        // 否则直接返回原始请求
        return observable
    }
}
