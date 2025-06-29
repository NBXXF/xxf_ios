//
//  Observable+Subscription.swift
//  xxf_ios
//
//  Created by xxf on /5/26.
//
import RxSwift

public extension ObservableType {
    func delaySubscription(_ delay: RxTimeInterval, scheduler: SchedulerType) -> Observable<Element> {
        return Observable.create { observer in
            let disposable = Disposables.create()
            _ = scheduler.scheduleRelative((), dueTime: delay) { _ in
                let subscription = self.subscribe(observer)
                return subscription
            }
            return disposable
        }
    }
}
