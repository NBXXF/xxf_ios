//
//  Observable+Observer.swift
//  xxf_ios
//
//  Created by xxf on /5/26.
//
import RxSwift

public extension PrimitiveSequenceType where Trait == SingleTrait {
    func doOnSubscribe(_ onSubscribe: @escaping () -> Void) -> PrimitiveSequence<Trait, Element> {
        return self.do(onSubscribe: onSubscribe)
    }

    func doOnNext(_ onNext: @escaping (Element) -> Void) -> PrimitiveSequence<Trait, Element> {
        return self.do(onSuccess: onNext)
    }

    func doAfterNext(_ afterNext: @escaping (Element) -> Void) -> PrimitiveSequence<Trait, Element> {
        return self.do(afterSuccess: afterNext)
    }

    func doOnError(_ onError: @escaping (Error) -> Void) -> PrimitiveSequence<Trait, Element> {
        return self.do(onError: onError)
    }

    func doAfterError(_ afterError: @escaping (Error) -> Void) -> PrimitiveSequence<Trait, Element> {
        return self.do(afterError: afterError)
    }

    func doOnDispose(_ onDispose: @escaping () -> Void) -> PrimitiveSequence<Trait, Element> {
        return self.do(onDispose: onDispose)
    }
}
