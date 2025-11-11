//
//  Single+Map.swift
//  xxf_ios
//
//  Created by xxf on7/26.
//

import RxSwift

public extension PrimitiveSequenceType where Trait == SingleTrait {
    /// 变换成空
    func mapVoid() -> PrimitiveSequence<Trait, Void> {
        return map { _ in
        }
    }
}
