//
//  Observable+XXFScheduler.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//

import RxSwift

public extension Observable {
    func subscribeOn(_ scheduler: ImmediateSchedulerType) -> Observable<Element> {
        return subscribe(on: scheduler)
    }

    func observeOn(_ scheduler: ImmediateSchedulerType) -> Observable<Element> {
        return observe(on: scheduler)
    }

    // MARK: 具体线程订阅

    func subscribeOnIO() -> Observable<Element> {
        return subscribeOn(Schedulers.io())
    }

    func subscribeOnComputation() -> Observable<Element> {
        return subscribeOn(Schedulers.computation())
    }

    func subscribeOnMain() -> Observable<Element> {
        return subscribeOn(Schedulers.main())
    }

    /// 对应主runloop的common mode，处理一些在模态下要触发的信号更新，如果耗时会影响滑动等UI
    func subscribeOnMainCommonMode() -> Observable<Element> {
        return subscribeOn(Schedulers.mainCommonMode())
    }

    func subscribeOnBackground() -> Observable<Element> {
        return subscribeOn(Schedulers.background())
    }

    func subscribeOnSingle() -> Observable<Element> {
        return subscribeOn(Schedulers.single())
    }

    func subscribeOnNewThread() -> Observable<Element> {
        return subscribeOn(Schedulers.newThread())
    }

    // MARK: 具体线程观察（observeOn）对应方法

    func observeOnIO() -> Observable<Element> {
        return observeOn(Schedulers.io())
    }

    func observeOnComputation() -> Observable<Element> {
        return observeOn(Schedulers.computation())
    }

    func observeOnMain() -> Observable<Element> {
        return observeOn(Schedulers.main())
    }

    /// 对应主runloop的common mode，处理一些在模态下要触发的信号更新，如果耗时会影响滑动等UI
    func observeOnMainCommonMode() -> Observable<Element> {
        return observeOn(Schedulers.mainCommonMode())
    }

    func observeOnBackground() -> Observable<Element> {
        return observeOn(Schedulers.background())
    }

    func observeOnSingle() -> Observable<Element> {
        return observeOn(Schedulers.single())
    }

    func observeOnNewThread() -> Observable<Element> {
        return observeOn(Schedulers.newThread())
    }
}
