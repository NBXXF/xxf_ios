//
//  Maybe+Map.swift
//  xxf_ios
//
//  Created by xxf on7/26.
//

import RxSwift

public extension PrimitiveSequenceType where Trait == MaybeTrait {
    /// 变换成空
    func mapVoid() -> PrimitiveSequence<MaybeTrait, Void> {
        return map { _ in
        }
    }
}
