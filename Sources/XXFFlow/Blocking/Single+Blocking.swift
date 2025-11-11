//
//  Single+Blocking.swift
//  xxf_ios
//  同步获取方法
//  Created by xxf on 7/9.
//

import Foundation

public extension PrimitiveSequence where Trait == SingleTrait {
    /// 阻塞式获取 Single 的值（RxJava 的 blockingGet 对应）
    func blockingGet(timeout: TimeInterval? = nil) throws -> Element {
        guard let value = try toBlocking(timeout: timeout).first() else {
            throw BlockingNoElementsError()
        }
        return value
    }
}
