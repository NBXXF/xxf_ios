//
//  Scheduler+Dispatch.swift
//  xxf_ios
//  可直接执行任务指定线程
//  Created by trl on 6/7.
//

import Foundation
import RxSwift

// MARK: - 通用调度封装

@discardableResult
public func scheduleDirect(scheduler: ImmediateSchedulerType, run: @escaping () -> Void) -> Disposable {
    return Observable<Void>.create { observer in
        run()
        observer.onCompleted()
        return Disposables.create()
    }
    .subscribe(on: scheduler)
    .subscribe()
}

@discardableResult
public func scheduleDirect(scheduler: SchedulerType, run: @escaping () -> Void, delay: RxTimeInterval) -> Disposable {
    return Observable<Void>.just(())
        .delay(delay, scheduler: scheduler)
        .do(onNext: { run() })
        .subscribe()
}

// MARK: - 各种 Scheduler 调用封装

@discardableResult
public func scheduleDirectOnMain(run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.main(), run: run)
}

@discardableResult
public func scheduleDirectOnMain(run: @escaping () -> Void, delay: RxTimeInterval) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.main(), run: run, delay: delay)
}

@discardableResult
public func scheduleDirectOnIO(run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.io(), run: run)
}

@discardableResult
public func scheduleDirectOnIO(run: @escaping () -> Void, delay: RxTimeInterval) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.io(), run: run, delay: delay)
}

@discardableResult
public func scheduleDirectOnComputation(run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.computation(), run: run)
}

@discardableResult
public func scheduleDirectOnComputation(run: @escaping () -> Void, delay: RxTimeInterval) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.computation(), run: run, delay: delay)
}

@discardableResult
public func scheduleDirectOnNewThread(run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.newThread(), run: run)
}

@discardableResult
public func scheduleDirectOnNewThread(run: @escaping () -> Void, delay: RxTimeInterval) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.newThread(), run: run, delay: delay)
}

@discardableResult
public func scheduleDirectOnSingle(run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.single(), run: run)
}

@discardableResult
public func scheduleDirectOnSingle(run: @escaping () -> Void, delay: RxTimeInterval) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.single(), run: run, delay: delay)
}

@discardableResult
public func scheduleDirectOnTrampoline(run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: CurrentThreadScheduler.instance, run: run)
}

// @discardableResult
// public func scheduleDirectOnTrampoline(run: @escaping () -> Void, delay: RxTimeInterval) -> Disposable {
//    return scheduleDirect(scheduler: CurrentThreadScheduler.instance, run: run, delay: delay)
// }
