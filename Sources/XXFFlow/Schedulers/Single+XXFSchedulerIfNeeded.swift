
//
//  Single+XXFSchedulerIfNeeded.swift
//  xxf_ios
//  提高效率,避免频繁切换队列
//  Created by xxf on 5/26.
//

import Foundation
import RxSwift

//
//  Single+XXFSchedulerIfNeeded.swift
//  xxf_ios
//  提高效率,避免频繁切换队列,复用线程
//  Created by xxf on 8/12.
//

import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {
    // MARK: - 工具方法（IfNeeded）

    /// 真正执行订阅的时候才切换
    internal func subscribeOnIfNeeded(_ scheduler: ImmediateSchedulerType, queueType: DispatchQueueType) -> PrimitiveSequence<Trait, Element> {
        return Single.deferred {
            if queueType.isCurrentDispatchQueue() {
                return self
            } else {
                return self.subscribe(on: scheduler)
            }
        }
    }

    /// 真正执行下游的时候才切换
    internal func observeOnIfNeeded(_ scheduler: ImmediateSchedulerType, queueType: DispatchQueueType) -> PrimitiveSequence<Trait, Element> {
        return flatMap { value in
            if queueType.isCurrentDispatchQueue() {
                return Single.just(value)
            } else {
                return Single.just(value).observe(on: scheduler)
            }
        }
    }

    // MARK: - 子线程订阅（IfNeeded,只判断是否是子线程）

    /// 仅仅不是子线程的时候才切换指定scheduler,默认新的独立线程
    /// - Parameter scheduler: 调度器
    /// - Returns: 信号
    func subscribeOnChildThreadIfNeeded(_ scheduler: ImmediateSchedulerType = Schedulers.newThread()) -> PrimitiveSequence<Trait, Element> {
        return Single.deferred {
            if Thread.isMainThread {
                return self.subscribe(on: scheduler)
            } else {
                return self
            }
        }
    }

    // MARK: - 子线程观察（IfNeeded,只判断是否是子线程）

    /// 仅仅不是子线程的时候才切换指定scheduler,默认新的独立线程
    /// - Parameter scheduler: 调度器
    /// - Returns: 信号
    func observeOnChildThreadIfNeeded(_ scheduler: ImmediateSchedulerType = Schedulers.newThread()) -> PrimitiveSequence<Trait, Element> {
        return flatMap { value in
            if Thread.isMainThread {
                return Single.just(value).observe(on: scheduler)
            } else {
                return Single.just(value)
            }
        }
    }

    // MARK: - 具体线程订阅（IfNeeded）

    func subscribeOnIOIfNeeded() -> PrimitiveSequence<Trait, Element> {
        return subscribeOnIfNeeded(Schedulers.io(), queueType: .io)
    }

    func subscribeOnComputationIfNeeded() -> PrimitiveSequence<Trait, Element> {
        return subscribeOnIfNeeded(Schedulers.computation(), queueType: .computation)
    }

    func subscribeOnMainIfNeeded() -> PrimitiveSequence<Trait, Element> {
        return subscribeOnIfNeeded(Schedulers.main(), queueType: .main)
    }

    func subscribeOnBackgroundIfNeeded() -> PrimitiveSequence<Trait, Element> {
        return subscribeOnIfNeeded(Schedulers.background(), queueType: .background)
    }

    func subscribeOnSingleIfNeeded() -> PrimitiveSequence<Trait, Element> {
        return subscribeOnIfNeeded(Schedulers.single(), queueType: .single)
    }

    func subscribeOnNewThreadIfNeeded() -> PrimitiveSequence<Trait, Element> {
        return subscribeOnIfNeeded(Schedulers.newThread(), queueType: .trampoline)
    }

    // MARK: - 具体线程观察（IfNeeded）

    func observeOnIOIfNeeded() -> PrimitiveSequence<Trait, Element> {
        return observeOnIfNeeded(Schedulers.io(), queueType: .io)
    }

    func observeOnComputationIfNeeded() -> PrimitiveSequence<Trait, Element> {
        return observeOnIfNeeded(Schedulers.computation(), queueType: .computation)
    }

    func observeOnMainIfNeeded() -> PrimitiveSequence<Trait, Element> {
        return observeOnIfNeeded(Schedulers.main(), queueType: .main)
    }

    func observeOnBackgroundIfNeeded() -> PrimitiveSequence<Trait, Element> {
        return observeOnIfNeeded(Schedulers.background(), queueType: .background)
    }

    func observeOnSingleIfNeeded() -> PrimitiveSequence<Trait, Element> {
        return observeOnIfNeeded(Schedulers.single(), queueType: .single)
    }

    func observeOnNewThreadIfNeeded() -> PrimitiveSequence<Trait, Element> {
        return observeOnIfNeeded(Schedulers.newThread(), queueType: .trampoline)
    }
}
