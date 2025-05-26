//
//  Observable+Subscription.swift
//  xxf_ios
//
//  Created by trl on 2025/5/26.
//
import RxSwift

extension ObservableType {
    func delaySubscription(_ delay: RxTimeInterval, scheduler: SchedulerType) -> Observable<Element> {
        return Observable.create { observer in
            let disposable = Disposables.create()
            scheduler.scheduleRelative((), dueTime: delay) { _ in
                let subscription = self.subscribe(observer)
                return subscription
            }
            return disposable
        }
    }
}
