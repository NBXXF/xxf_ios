//
//  MoyaProvider+RxStream.swift
//  xxf_ios
//  rxswift 来做stream流
//  Created by xxf on /6/9.
//

import Alamofire
import Foundation
import Moya
@preconcurrency import RxSwift

public extension Reactive where Base: MoyaProviderType, Base.Target: Sendable {
    /// 原始 Data 流 Observable
    func requestStream(_ token: Base.Target,
                       callbackQueue: DispatchQueue? = .none) -> Observable<Data>
    {
        Observable.create { observer in
            // 更安全地转换
            guard let provider = base as? MoyaProvider<Base.Target> else {
                observer.onError(AFError.explicitlyCancelled)
                return Disposables.create()
            }
            let streamRequest = provider.requestStream(token, callbackQueue: callbackQueue) { wrapper in
                switch wrapper.event {
                    case let .stream(result):
                        switch result {
                            case let .success(model):
                                observer.onNext(model)
                            case let .failure(err):
                                observer.onError(err)
                        }
                    case let .complete(result):
                        /// 继续分发完成
                        if let error = result.error {
                            // 如果是取消，不当作错误
                            if case AFError.explicitlyCancelled = error {
                                observer.onCompleted()
                            } else {
                                observer.onError(error)
                            }
                        } else {
                            observer.onCompleted()
                        }
                }
            }

            return Disposables.create { streamRequest.cancel() }
        }
    }

    /// UTF8 String 流 Observable
    func requestStreamString(_ token: Base.Target,
                             callbackQueue: DispatchQueue? = .none) -> Observable<String>
    {
        Observable.create { observer in
            // 更安全地转换
            guard let provider = base as? MoyaProvider<Base.Target> else {
                observer.onError(AFError.explicitlyCancelled)
                return Disposables.create()
            }
            let streamRequest = provider.requestStreamString(token, callbackQueue: callbackQueue) { wrapper in
                switch wrapper.event {
                    case let .stream(result):
                        switch result {
                            case let .success(model):
                                observer.onNext(model)
                            case let .failure(err):
                                observer.onError(err)
                        }
                    case let .complete(result):
                        /// 继续分发完成
                        if let error = result.error {
                            // 如果是取消，不当作错误
                            if case AFError.explicitlyCancelled = error {
                                observer.onCompleted()
                            } else {
                                observer.onError(error)
                            }
                        } else {
                            observer.onCompleted()
                        }
                }
            }

            return Disposables.create { streamRequest.cancel() }
        }
    }

    /// Decodable 解码流 Observable
    func requestStreamDecodable<T: Decodable & Sendable>(
        _ token: Base.Target,
        type: T.Type = T.self,
        callbackQueue: DispatchQueue? = .none,
        decoder: any Alamofire.DataDecoder = JSONDecoder(),
        preprocessor: any DataPreprocessor = PassthroughPreprocessor()
    ) -> Observable<T> {
        Observable.create { observer in
            // 更安全地转换
            guard let provider = base as? MoyaProvider<Base.Target> else {
                observer.onError(AFError.explicitlyCancelled)
                return Disposables.create()
            }
            let streamRequest = provider.requestStreamDecodable(
                token,
                type: type,
                callbackQueue: callbackQueue,
                decoder: decoder,
                preprocessor: preprocessor
            ) { wrapper in
                switch wrapper.event {
                    case let .stream(result):
                        switch result {
                            case let .success(model):
                                observer.onNext(model)
                            case let .failure(err):
                                observer.onError(err)
                        }
                    case let .complete(result):
                        /// 继续分发完成
                        if let error = result.error {
                            // 如果是取消，不当作错误
                            if case AFError.explicitlyCancelled = error {
                                observer.onCompleted()
                            } else {
                                observer.onError(error)
                            }
                        } else {
                            observer.onCompleted()
                        }
                }
            }

            return Disposables.create { streamRequest.cancel() }
        }
    }
}
