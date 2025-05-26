
//
//  Observable+Subscription.swift
//  xxf_ios
//
//  Created by trl on 2025/5/26.
//
import RxSwift

extension ObservableType where Element: ObservableType {
    static func combineLatestArray(_ sources: [Observable<Element.Element>]) -> Observable<[Element.Element]> {
        guard !sources.isEmpty else {
            return Observable.just([])
        }
        return Observable.combineLatest(sources)
    }
}
