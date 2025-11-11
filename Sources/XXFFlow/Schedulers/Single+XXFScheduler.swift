
//
//  Single+XXFScheduler.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//

import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {
    func subscribeOn(_ scheduler: ImmediateSchedulerType) -> PrimitiveSequence<Trait, Element> {
        return subscribe(on: scheduler)
    }

    func observeOn(_ scheduler: ImmediateSchedulerType) -> PrimitiveSequence<Trait, Element> {
        return observe(on: scheduler)
    }

    // MARK: 具体线程订阅

    func subscribeOnIO() -> PrimitiveSequence<Trait, Element> {
        return subscribeOn(Schedulers.io())
    }

    func subscribeOnComputation() -> PrimitiveSequence<Trait, Element> {
        return subscribeOn(Schedulers.computation())
    }

    func subscribeOnMain() -> PrimitiveSequence<Trait, Element> {
        return subscribeOn(Schedulers.main())
    }

    func subscribeOnBackground() -> PrimitiveSequence<Trait, Element> {
        return subscribeOn(Schedulers.background())
    }

    func subscribeOnSingle() -> PrimitiveSequence<Trait, Element> {
        return subscribeOn(Schedulers.single())
    }

    func subscribeOnNewThread() -> PrimitiveSequence<Trait, Element> {
        return subscribeOn(Schedulers.newThread())
    }

    // MARK: 具体线程观察（observeOn）对应方法

    func observeOnIO() -> PrimitiveSequence<Trait, Element> {
        return observeOn(Schedulers.io())
    }

    func observeOnComputation() -> PrimitiveSequence<Trait, Element> {
        return observeOn(Schedulers.computation())
    }

    func observeOnMain() -> PrimitiveSequence<Trait, Element> {
        return observeOn(Schedulers.main())
    }

    func observeOnBackground() -> PrimitiveSequence<Trait, Element> {
        return observeOn(Schedulers.background())
    }

    func observeOnSingle() -> PrimitiveSequence<Trait, Element> {
        return observeOn(Schedulers.single())
    }

    func observeOnNewThread() -> PrimitiveSequence<Trait, Element> {
        return observeOn(Schedulers.newThread())
    }
}
