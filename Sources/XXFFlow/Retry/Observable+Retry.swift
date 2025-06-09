//
//  Observable+Retry.swift
//  xxf_ios
//
//  Created by xxf on /5/26.
//

import RxSwift

public extension ObservableType {
    /// 重试指定次数，每次重试间隔 delay 毫秒（异步延迟，不阻塞线程）
    /// - Parameters:
    ///   - times: 重试次数
    ///   - delayMillis: 延迟毫秒数
    /// - Returns: Observable
    func retryDelay(times: Int, delayMillis: Int) -> Observable<Element> {
        return retry { (errors: Observable<Error>) in
            errors.enumerated().flatMap { attempt, error -> Observable<Void> in
                if attempt >= times {
                    return Observable.error(error)
                }
                return Observable.just(())
                    .delay(.milliseconds(delayMillis), scheduler: MainScheduler.instance)
            }
        }
    }

    /// 重试指定次数，每次重试间隔 delay 毫秒（异步延迟，不阻塞线程）
    /// 带错误过滤条件，满足条件时才重试
    /// - Parameters:
    ///   - times: 重试次数
    ///   - delayMillis: 延迟毫秒数
    ///   - predicate: 判断是否重试的条件闭包
    /// - Returns: Observable
    func retryDelay(times: Int, delayMillis: Int, predicate: @escaping (Error) -> Bool) -> Observable<Element> {
        return retry { (errors: Observable<Error>) in
            errors.enumerated().flatMap { attempt, error -> Observable<Void> in
                if attempt >= times || !predicate(error) {
                    return Observable.error(error)
                }
                return Observable.just(())
                    .delay(.milliseconds(delayMillis), scheduler: MainScheduler.instance)
            }
        }
    }
}
