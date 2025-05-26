//
//  Observable+Subscription.swift
//  xxf_ios
//
//  Created by trl on 2025/5/26.
//
import RxSwift

extension ObservableType {
    func ifEmpty(default defaultValue: Element) -> Observable<Element> {
        return ifEmpty(switchTo: Observable.just(defaultValue))
    }
}
