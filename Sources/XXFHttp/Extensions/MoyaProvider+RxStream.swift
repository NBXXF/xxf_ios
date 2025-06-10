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

public extension Reactive where Base: MoyaProviderType {
    /// 原始 Data 流 Observable
    func requestStream(_ target: Base.Target,
                       callbackQueue: DispatchQueue = .main) -> Observable<Data>
    {
        Observable.create { observer in
            // 更安全地转换
            guard let provider = base as? MoyaProvider<Base.Target> else {
                observer.onError(AFError.explicitlyCancelled)
                return Disposables.create()
            }
            let streamRequest = provider.requestStream(target, callbackQueue: callbackQueue) { wrapper in
                switch wrapper.event {
                case let .stream(result):
                    switch result {
                    case let .success(model):
                        observer.onNext(model)
                    case let .failure(err):
                        observer.onError(err)
                    }
                case .complete:
                    observer.onCompleted()
                }
            }

            return Disposables.create { streamRequest.cancel() }
        }
    }

    /// UTF8 String 流 Observable
    func requestStreamString(_ target: Base.Target,
                             callbackQueue: DispatchQueue = .main) -> Observable<String>
    {
        Observable.create { observer in
            // 更安全地转换
            guard let provider = base as? MoyaProvider<Base.Target> else {
                observer.onError(AFError.explicitlyCancelled)
                return Disposables.create()
            }
            let streamRequest = provider.requestStreamString(target, callbackQueue: callbackQueue) { wrapper in
                switch wrapper.event {
                case let .stream(result):
                    switch result {
                    case let .success(model):
                        observer.onNext(model)
                    case let .failure(err):
                        observer.onError(err)
                    }
                case .complete:
                    observer.onCompleted()
                }
            }

            return Disposables.create { streamRequest.cancel() }
        }
    }

    /// Decodable 解码流 Observable
    func requestStreamDecodable<T: Decodable & Sendable>(
        _ target: Base.Target,
        type: T.Type = T.self,
        callbackQueue: DispatchQueue = .main,
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
                target,
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
                case .complete:
                    observer.onCompleted()
                }
            }

            return Disposables.create { streamRequest.cancel() }
        }
    }
}
