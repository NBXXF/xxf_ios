//
//  Single+Blocking.swift
//  xxf_ios
//  同步获取方法
//  Created by xxf on 7/9.
//

public extension PrimitiveSequence where Trait == SingleTrait {
    /// 阻塞式获取 Single 的值（RxJava 的 blockingGet 对应）
    func blockingGet() throws -> Element {
        guard let value = try toBlocking().first() else {
            fatalError("Single did not emit a value")
        }
        return value
    }
}
