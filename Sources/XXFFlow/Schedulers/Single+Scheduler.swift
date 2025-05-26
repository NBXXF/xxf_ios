
//
//  Single+Scheduler.swift
//  xxf_ios
//
//  Created by trl on 2025/5/26.
//

import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {
    func subscribeOnIO() -> PrimitiveSequence<Trait, Element> {
        return subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func observeOnMain() -> PrimitiveSequence<Trait, Element> {
        return observe(on: MainScheduler.instance)
    }
}
