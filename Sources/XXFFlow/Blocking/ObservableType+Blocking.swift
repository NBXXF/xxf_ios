//
//  ObservableType+Blocking.swift
//  xxf_ios
//  同步获取方法
//  Created by xxf on 7/9.
//

import RxBlocking
import RxSwift

// MARK: - ObservableType 扩展（适用于 Observable）

public extension ObservableType {
    /// 阻塞式获取第一个元素（建议仅用于测试或调试）
    func blockingFirst() throws -> Element? {
        try toBlocking().first()
    }

    /// 阻塞式获取最后一个元素
    func blockingLast() throws -> Element? {
        try toBlocking().last()
    }

    /// 阻塞式获取所有元素为数组
    func blockingGet() throws -> [Element] {
        try toBlocking().toArray()
    }
}
