//
//  Maybe+Scheduler.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/26.
//

import RxSwift

public extension PrimitiveSequence where Trait == MaybeTrait {
    func subscribeOn(_ scheduler: ImmediateSchedulerType) -> PrimitiveSequence<Trait, Element> {
        return subscribe(on: scheduler)
    }

    func observeOn(_ scheduler: ImmediateSchedulerType) -> PrimitiveSequence<Trait, Element> {
        return observe(on: scheduler)
    }

    func subscribeOnIO() -> PrimitiveSequence<Trait, Element> {
        return subscribeOn(Schedulers.io())
    }

    func observeOnMain() -> PrimitiveSequence<Trait, Element> {
        return observeOn(Schedulers.main())
    }
}
