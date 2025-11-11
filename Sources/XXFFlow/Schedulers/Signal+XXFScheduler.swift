//
//  Signal+XXFScheduler.swift
//  xxf_ios
//
//  Created by xxf on 5/7/30.
//

import RxCocoa
import RxSwift

public extension Signal {
    func subscribeOn(_ scheduler: SchedulerType) -> Signal<Element> {
        return asObservable()
            .subscribe(on: scheduler)
            .asSignal(onErrorSignalWith: .empty())
    }

    func observeOn(_ scheduler: SchedulerType) -> Signal<Element> {
        return asObservable()
            .observe(on: scheduler)
            .asSignal(onErrorSignalWith: .empty())
    }

    func subscribeOnIO() -> Signal<Element> {
        subscribeOn(Schedulers.io())
    }

    func observeOnMain() -> Signal<Element> {
        observeOn(Schedulers.main())
    }
}
