//
//  Observable+XXFSchedulerIfNeeded.swift
//  xxf_ios
//  提高效率,避免频繁切换队列,复用线程
//  Created by xxf on 8/12.
//

import Foundation
import RxSwift

import RxSwift

public extension Observable {
    // MARK: - 工具方法（IfNeeded）

    /// 真正执行订阅的时候才切换
    internal func subscribeOnIfNeeded(_ scheduler: ImmediateSchedulerType, queueType: DispatchQueueType) -> Observable<Element> {
        return Observable.deferred {
            if queueType.isCurrentDispatchQueue() {
                return self
            } else {
                return self.subscribe(on: scheduler)
            }
        }
    }

    /// 真正执行下游的时候才切换
    internal func observeOnIfNeeded(_ scheduler: ImmediateSchedulerType, queueType: DispatchQueueType) -> Observable<Element> {
        return flatMap { value in
            if queueType.isCurrentDispatchQueue() {
                return Observable.just(value)
            } else {
                return Observable.just(value).observe(on: scheduler)
            }
        }
    }

    // MARK: - 子线程订阅（IfNeeded,只判断是否是子线程）

    /// 仅仅不是子线程的时候才切换指定scheduler,默认新的独立线程
    /// - Parameter scheduler: 调度器
    /// - Returns: 信号
    func subscribeOnChildThreadIfNeeded(_ scheduler: ImmediateSchedulerType = Schedulers.newThread()) -> Observable<Element> {
        return Observable.deferred {
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
    func observeOnChildThreadIfNeeded(_ scheduler: ImmediateSchedulerType = Schedulers.newThread()) -> Observable<Element> {
        return flatMap { value in
            if Thread.isMainThread {
                return Observable.just(value).observe(on: scheduler)
            } else {
                return Observable.just(value)
            }
        }
    }

    // MARK: - 具体线程订阅（IfNeeded）

    func subscribeOnIOIfNeeded() -> Observable<Element> {
        return subscribeOnIfNeeded(Schedulers.io(), queueType: .io)
    }

    func subscribeOnComputationIfNeeded() -> Observable<Element> {
        return subscribeOnIfNeeded(Schedulers.computation(), queueType: .computation)
    }

    func subscribeOnMainIfNeeded() -> Observable<Element> {
        return subscribeOnIfNeeded(Schedulers.main(), queueType: .main)
    }

    func subscribeOnBackgroundIfNeeded() -> Observable<Element> {
        return subscribeOnIfNeeded(Schedulers.background(), queueType: .background)
    }

    func subscribeOnSingleIfNeeded() -> Observable<Element> {
        return subscribeOnIfNeeded(Schedulers.single(), queueType: .single)
    }

    func subscribeOnNewThreadIfNeeded() -> Observable<Element> {
        return subscribeOnIfNeeded(Schedulers.newThread(), queueType: .trampoline) // 你这里用合适的枚举值
    }

    // MARK: - 具体线程观察（observeOnIfNeeded）

    func observeOnIOIfNeeded() -> Observable<Element> {
        return observeOnIfNeeded(Schedulers.io(), queueType: .io)
    }

    func observeOnComputationIfNeeded() -> Observable<Element> {
        return observeOnIfNeeded(Schedulers.computation(), queueType: .computation)
    }

    func observeOnMainIfNeeded() -> Observable<Element> {
        return observeOnIfNeeded(Schedulers.main(), queueType: .main)
    }

    func observeOnBackgroundIfNeeded() -> Observable<Element> {
        return observeOnIfNeeded(Schedulers.background(), queueType: .background)
    }

    func observeOnSingleIfNeeded() -> Observable<Element> {
        return observeOnIfNeeded(Schedulers.single(), queueType: .single)
    }

    func observeOnNewThreadIfNeeded() -> Observable<Element> {
        return observeOnIfNeeded(Schedulers.newThread(), queueType: .trampoline)
    }
}
