//
//  SharedSequenceConvertibleType+XXFObserver.swift
//  xxf_ios
//
//  Created by xxf on 7/30.
//

import RxCocoa
import RxSwift

public extension SharedSequenceConvertibleType {
    func doOnSubscribe(_ onSubscribe: @escaping () -> Void) -> SharedSequence<SharingStrategy, Element> {
        return self.do(onSubscribe: onSubscribe)
    }

    func doOnSubscribed(_ onSubscribed: @escaping () -> Void) -> SharedSequence<SharingStrategy, Element> {
        return self.do(onSubscribed: onSubscribed)
    }

    func doOnNext(_ onNext: @escaping (Element) -> Void) -> SharedSequence<SharingStrategy, Element> {
        return self.do(onNext: onNext)
    }

    func doAfterNext(_ afterNext: @escaping (Element) -> Void) -> SharedSequence<SharingStrategy, Element> {
        return self.do(afterNext: afterNext)
    }

    func doOnCompleted(_ onCompleted: @escaping () -> Void) -> SharedSequence<SharingStrategy, Element> {
        return self.do(onCompleted: onCompleted)
    }

    func doAfterCompleted(_ afterCompleted: @escaping () -> Void) -> SharedSequence<SharingStrategy, Element> {
        return self.do(afterCompleted: afterCompleted)
    }

    func doOnDispose(_ onDispose: @escaping () -> Void) -> SharedSequence<SharingStrategy, Element> {
        return self.do(onDispose: onDispose)
    }

    func doOnFinal(_ final: @escaping () -> Void) -> SharedSequence<SharingStrategy, Element> {
        return self
            .do(afterCompleted: final)
            .do(onDispose: final)
    }
}
