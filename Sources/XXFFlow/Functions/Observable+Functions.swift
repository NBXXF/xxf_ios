//
//  Observable+Fou.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/26.
//
import RxSwift

extension ObservableType {
    func switchMap<R>(_ transform: @escaping (Element) -> Observable<R>) -> Observable<R> {
        return flatMapLatest(transform)
    }

    func throttleFirst(_ dueTime: RxTimeInterval, scheduler: SchedulerType) -> Observable<Element> {
        let shared = publish().refCount()
        return shared
            .window(timeSpan: dueTime, count: 1, scheduler: scheduler)
            .flatMap { $0.take(1) }
    }
}
