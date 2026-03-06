//
//  DispatchQueueType.swift
//  xxf_ios
//
//  Created by xxf on 2026/8/12.
//
import Dispatch
import Foundation

/// queue的类型
enum DispatchQueueType: Sendable {
    /// queue关联的类别
    static let specificKey = DispatchSpecificKey<DispatchQueueType>()

    /// 常用级别
    case io

    /// 高级别
    case computation

    /// 主线程
    case main

    /// 单线程子线程模型
    case single

    /// 后台子线程
    case background

    /// 最高优先级子线程
    case userInteractive

    /// 当前线程
    case trampoline

    /// 判断当前队列是不是具体类型
    /// - Returns: true
    func isCurrentDispatchQueue() -> Bool {
        if self == .main {
            return Thread.isMainThread
        }
        return DispatchQueue.getSpecific(key: Self.specificKey) == self
    }
}
