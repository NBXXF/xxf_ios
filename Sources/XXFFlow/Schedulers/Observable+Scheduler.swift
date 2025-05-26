//
//  Observable+Scheduler.swift
//  xxf_ios
//
//  Created by trl on 2025/5/26.
//

import RxSwift

public extension Observable {
    func subscribeOnIo() -> Observable<Element> {
        return subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }

    func observeOnMain() -> Observable<Element> {
        return observe(on: MainScheduler.instance)
    }
}
