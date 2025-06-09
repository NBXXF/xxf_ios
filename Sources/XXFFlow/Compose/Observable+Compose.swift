//
//  Observable+Compose.swift
//  xxf_ios
//
//  Created by xxf on /5/26.
//

import RxSwift

public extension ObservableType {
    func compose<R>(
        _ transform: @escaping (Observable<Element>) -> Observable<R>
    ) -> Observable<R> {
        return transform(asObservable())
    }
}
