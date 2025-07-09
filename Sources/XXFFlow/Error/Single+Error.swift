//
//  Single+Error.swift
//  xxf_ios
//
//  Created by xxf on 7/9.
//
import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {
    /// 忽略错误：出错时永不结束也不触发 onError
    func ignoreError() -> PrimitiveSequence<SingleTrait, Element> {
        return catchError { _ in
            PrimitiveSequence<SingleTrait, Element>.never()
        }
    }
}
