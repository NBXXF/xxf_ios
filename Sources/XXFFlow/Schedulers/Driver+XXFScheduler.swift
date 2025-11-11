//
//  Driver+XXFScheduler.swift
//  xxf_ios
//
//  Created by xxf on 7/30.
//

import RxCocoa
import RxSwift

public extension Driver {
    func subscribeOn(_ scheduler: SchedulerType) -> Driver<Element> {
        return asObservable()
            .subscribe(on: scheduler)
            .asDriver(onErrorDriveWith: .empty())
    }

    func observeOn(_ scheduler: SchedulerType) -> Driver<Element> {
        return asObservable()
            .observe(on: scheduler)
            .asDriver(onErrorDriveWith: .empty())
    }

    // MARK: subscribeOnXXX

    func subscribeOnIO() -> Driver<Element> {
        return subscribeOn(Schedulers.io())
    }

    func subscribeOnComputation() -> Driver<Element> {
        return subscribeOn(Schedulers.computation())
    }

    func subscribeOnMain() -> Driver<Element> {
        return subscribeOn(Schedulers.main())
    }

    func subscribeOnBackground() -> Driver<Element> {
        return subscribeOn(Schedulers.background())
    }

    func subscribeOnSingle() -> Driver<Element> {
        return subscribeOn(Schedulers.single())
    }

    func subscribeOnNewThread() -> Driver<Element> {
        return subscribeOn(Schedulers.newThread())
    }

    // MARK: observeOnXXX

    func observeOnIO() -> Driver<Element> {
        return observeOn(Schedulers.io())
    }

    func observeOnComputation() -> Driver<Element> {
        return observeOn(Schedulers.computation())
    }

    func observeOnMain() -> Driver<Element> {
        return observeOn(Schedulers.main())
    }

    func observeOnBackground() -> Driver<Element> {
        return observeOn(Schedulers.background())
    }

    func observeOnSingle() -> Driver<Element> {
        return observeOn(Schedulers.single())
    }

    func observeOnNewThread() -> Driver<Element> {
        return observeOn(Schedulers.newThread())
    }
}
