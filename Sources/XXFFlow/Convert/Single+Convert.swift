//
//  Single+Convert.swift
//  xxf_ios
//
//  Created by trl on 2025/5/26.
//
import RxSwift

extension PrimitiveSequence where Trait == SingleTrait {
    func toCompletable() -> Completable {
        return asCompletable()
    }
}
