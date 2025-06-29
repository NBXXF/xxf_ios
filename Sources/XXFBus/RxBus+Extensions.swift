//
//  RxBus+Extensions.swift
//  xxf_ios
//
//  Created by xxf on 6/29.
//

import RxSwift

public extension RxBus {
    func postAction<T: Sendable>(_ action: String, data: T?) {
        post(ActionTypeEvent<T>.create(action: action, data: data))
    }

    func observeAction<T: Sendable>(_ action: String, type _: T.Type) -> Observable<T> {
        return observe(ActionTypeEvent<T>.self)
            .filter { $0.action == action }
            .compactMap { $0.data }
    }

    func observeStickyAction<T: Sendable>(_ action: String, type _: T.Type) -> Observable<T> {
        return observeSticky(ActionTypeEvent<T>.self)
            .filter { $0.action == action }
            .compactMap { $0.data }
    }
}
