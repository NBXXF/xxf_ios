//
//  ObservableType+Blocking.swift
//  xxf_ios
//  同步获取方法
//  Created by xxf on 7/9.
//
import Foundation
import RxBlocking
import RxSwift

public extension PrimitiveSequence where Trait == MaybeTrait {
    /// 阻塞式获取 Maybe 的值（可为 nil）
    func blockingGet(timeout: TimeInterval? = nil) throws -> Element? {
        try toBlocking(timeout: timeout).first()
    }
}
