//
//  Single+Retry.swift
//  xxf_ios
//  重试
//  Created by xxf on 5/26.
//
import ObjectiveC
import RxCocoa
import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {
    /// 重试指定次数，每次重试间隔 delay 毫秒（异步延迟，不阻塞线程）
    /// - Parameters:
    ///   - maxAttemptCount: 重试次数
    ///   - delayTime: 每次重试延迟时间
    /// - Returns: Observable
    func retry(_ maxAttemptCount: Int,
               delay delayTime: RxTimeInterval,
               scheduler: SchedulerType = Schedulers.background()) -> Single<Element>
    {
        return asObservable()
            .retry(maxAttemptCount,
                   delay: delayTime,
                   scheduler: scheduler)
            .asSingle()
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
               predicate: @escaping (Error) -> Bool) -> Single<Element>
    {
        return asObservable()
            .retry(maxAttemptCount,
                   delay: delayTime,
                   scheduler: scheduler,
                   predicate: predicate)
            .asSingle()
    }
}
