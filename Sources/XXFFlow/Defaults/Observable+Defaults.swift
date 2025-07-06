//
//  Observable+Subscription.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//
import RxSwift

public extension ObservableType {
    func ifEmpty(default defaultValue: Element) -> Observable<Element> {
        return ifEmpty(switchTo: Observable.just(defaultValue))
    }
}
