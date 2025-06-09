//
//  Observable+Observer.swift
//  xxf_ios
//
//  Created by xxf on /5/26.
//
import RxSwift

public extension PrimitiveSequenceType where Trait == MaybeTrait {
    func doOnSubscribe(_ onSubscribe: @escaping () -> Void) -> PrimitiveSequence<MaybeTrait, Element> {
        return self.do(onSubscribe: onSubscribe)
    }

    func doOnSubscribed(_ onSubscribed: @escaping () -> Void) -> PrimitiveSequence<MaybeTrait, Element> {
        return self.do(onSubscribed: onSubscribed)
    }

    func doOnNext(_ onNext: @escaping ((Element) throws -> Void)) -> PrimitiveSequence<MaybeTrait, Element> {
        return self.do(onNext: onNext)
    }

    func doAfterNext(_ afterNext: @escaping ((Element) throws -> Void)) -> PrimitiveSequence<MaybeTrait, Element> {
        return self.do(afterNext: afterNext)
    }

    func doOnCompleted(_ onCompleted: @escaping () -> Void) -> PrimitiveSequence<MaybeTrait, Element> {
        return self.do(onCompleted: onCompleted)
    }

    func doAfterCompleted(_ afterCompleted: @escaping () -> Void) -> PrimitiveSequence<MaybeTrait, Element> {
        return self.do(afterCompleted: afterCompleted)
    }

    func doOnError(_ onError: @escaping (Error) -> Void) -> PrimitiveSequence<MaybeTrait, Element> {
        return self.do(onError: onError)
    }

    func doAfterError(_ afterError: @escaping (Error) -> Void) -> PrimitiveSequence<MaybeTrait, Element> {
        return self.do(afterError: afterError)
    }

    func doOnDispose(_ onDispose: @escaping () -> Void) -> PrimitiveSequence<MaybeTrait, Element> {
        return self.do(onDispose: onDispose)
    }
}
