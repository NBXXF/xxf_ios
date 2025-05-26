//
//  Observable+Observer.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/26.
//
import RxSwift

extension ObservableType {
    func doOnNext(_ onNext: @escaping (Element) -> Void) -> Observable<Element> {
        return self.do(onNext: onNext)
    }

    func doOnCompleted(_ onCompleted: @escaping () -> Void) -> Observable<Element> {
        return self.do(onCompleted: onCompleted)
    }

    func doOnError(_ onError: @escaping (Error) -> Void) -> Observable<Element> {
        return self.do(onError: onError)
    }
}
