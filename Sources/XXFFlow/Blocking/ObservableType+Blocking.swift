//
//  ObservableType+Blocking.swift
//  xxf_ios
//  同步获取方法
//  Created by xxf on 7/9.
//

import Foundation
import RxBlocking
import RxSwift

// MARK: - ObservableType 扩展（适用于 Observable）

public extension ObservableType {
    /// 阻塞式获取第一个元素（建议仅用于测试或调试）
    func blockingFirst(timeout: TimeInterval? = nil) throws -> Element? {
        try toBlocking(timeout: timeout).first()
    }

    /// 阻塞式获取最后一个元素
    func blockingLast(timeout: TimeInterval? = nil) throws -> Element? {
        try toBlocking(timeout: timeout).last()
    }

    /// 阻塞式获取所有元素为数组
    func blockingGet(timeout: TimeInterval? = nil) throws -> [Element] {
        try toBlocking(timeout: timeout).toArray()
    }
}
