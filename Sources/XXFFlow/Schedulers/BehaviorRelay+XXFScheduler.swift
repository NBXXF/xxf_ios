//
//  BehaviorRelay+XXFScheduler.swift
//  xxf_ios
//
//  Created by xxf on 7/30.
//

import RxCocoa
import RxSwift

public extension BehaviorRelay {
    // MARK: subscribeOn

    func subscribeOn(_ scheduler: ImmediateSchedulerType) -> Observable<Element> {
        return subscribe(on: scheduler)
    }

    func subscribeOnIO() -> Observable<Element> {
        return subscribe(on: Schedulers.io())
    }

    func subscribeOnComputation() -> Observable<Element> {
        return subscribe(on: Schedulers.computation())
    }

    func subscribeOnMain() -> Observable<Element> {
        return subscribe(on: Schedulers.main())
    }

    func subscribeOnBackground() -> Observable<Element> {
        return subscribe(on: Schedulers.background())
    }

    func subscribeOnSingle() -> Observable<Element> {
        return subscribe(on: Schedulers.single())
    }

    func subscribeOnNewThread() -> Observable<Element> {
        return subscribe(on: Schedulers.newThread())
    }

    // MARK: observeOn

    func observeOn(_ scheduler: ImmediateSchedulerType) -> Observable<Element> {
        return observe(on: scheduler)
    }

    func observeOnIO() -> Observable<Element> {
        return observe(on: Schedulers.io())
    }

    func observeOnComputation() -> Observable<Element> {
        return observe(on: Schedulers.computation())
    }

    func observeOnMain() -> Observable<Element> {
        return observe(on: Schedulers.main())
    }

    func observeOnBackground() -> Observable<Element> {
        return observe(on: Schedulers.background())
    }

    func observeOnSingle() -> Observable<Element> {
        return observe(on: Schedulers.single())
    }

    func observeOnNewThread() -> Observable<Element> {
        return observe(on: Schedulers.newThread())
    }
}
