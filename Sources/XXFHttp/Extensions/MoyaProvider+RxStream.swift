//
//  MoyaProvider+RxStream.swift
//  xxf_ios
//  rxswift 来做stream流
//  Created by trl on /6/9.
//

import Alamofire
import Foundation
import Moya
@preconcurrency import RxSwift

public extension Reactive where Base: MoyaProviderType {
    /// 原始 Data 流 Observable
    func requestStream(_ target: Base.Target,
                       on queue: DispatchQueue = .main) -> Observable<Data>
    {
        Observable.create { observer in
            // 更安全地转换
            guard let provider = base as? MoyaProvider<Base.Target> else {
                observer.onError(AFError.explicitlyCancelled)
                return Disposables.create()
            }
            let streamRequest = provider.requestStream(target, on: queue) { wrapper in
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
                             on queue: DispatchQueue = .main) -> Observable<String>
    {
        Observable.create { observer in
            // 更安全地转换
            guard let provider = base as? MoyaProvider<Base.Target> else {
                observer.onError(AFError.explicitlyCancelled)
                return Disposables.create()
            }
            let streamRequest = provider.requestStreamString(target, on: queue) { wrapper in
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
        of type: T.Type = T.self,
        on queue: DispatchQueue = .main,
        using decoder: any Alamofire.DataDecoder = JSONDecoder(),
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
                of: type,
                on: queue,
                using: decoder,
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
