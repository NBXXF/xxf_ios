//
//  Observable+Scheduler.swift
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

    func subscribeOnIO() -> Observable<Element> {
        return subscribeOn(Schedulers.io())
    }

    func observeOnMain() -> Observable<Element> {
        return observeOn(Schedulers.main())
    }
}
