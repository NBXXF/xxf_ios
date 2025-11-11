//
//  Observable+Retry.swift
//  xxf_ios
//  重试
//  Created by xxf on 5/26.
//

import RxSwift

public extension ObservableType {
    /// 重试指定次数，每次重试间隔 delay 毫秒（异步延迟，不阻塞线程）
    /// - Parameters:
    ///   - maxAttemptCount: 重试次数
    ///   - delayTime: 每次重试延迟时间
    /// - Returns: Observable
    func retry(_ maxAttemptCount: Int,
               delay delayTime: RxTimeInterval,
               scheduler: SchedulerType = Schedulers.background()) -> Observable<Element>
    {
        return retry { (errors: Observable<Error>) in
            errors.enumerated().flatMap { attempt, error -> Observable<Void> in
                if attempt >= maxAttemptCount {
                    return Observable.error(error)
                }
                return Observable.just(())
                    .delay(delayTime, scheduler: scheduler)
            }
        }
    }

    /// 重试指定次数，每次重试间隔 delay 毫秒（异步延迟，不阻塞线程）
    /// 带错误过滤条件，满足条件时才重试
    /// - Parameters:
    ///   - maxAttemptCount: 重试次数
    ///   - delayTime: 每次重试延迟时间
    ///   - predicate: 判断是否重试的条件闭包
    /// - Returns: Observable
    func retry(_ maxAttemptCount: Int,
               delay delayTime: RxTimeInterval,
               scheduler: SchedulerType = Schedulers.background(),
               predicate: @escaping (Error) -> Bool) -> Observable<Element>
    {
        return retry { (errors: Observable<Error>) in
            errors.enumerated().flatMap { attempt, error -> Observable<Void> in
                if attempt >= maxAttemptCount || !predicate(error) {
                    return Observable.error(error)
                }
                return Observable.just(())
                    .delay(delayTime, scheduler: scheduler)
            }
        }
    }
}
