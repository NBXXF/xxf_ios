//
//  NSLocking+XXFExtension.swift
//  xxf_ios
//  锁的简化block回调
//  Created by xxf on 8/21.
//
import Foundation

/**
 NSLocking 实现类概览
 类名                                  继承关系                        特点                                                           优点                                                                           美中不足 / 限制                                   适用场景
 NSLock                            NSObject,                     NSLocking                                                 最基本的互斥锁    简单、易用                                   不支持递归；公平性不保证                   普通互斥保护资源
 NSRecursiveLock           NSLock                         支持递归加锁                                             同一线程可以重复加锁，不会死锁                             性能比 NSLock 略低                            递归调用或闭包中再次需要锁的情况
 NSCondition                NSObject, NSLocking       条件锁，带 wait()/signal()/broadcast()     可用于线程等待/通知                                                  使用复杂，需要配合 while 判断条件      生产者-消费者模式、多线程同步
 NSConditionLock        NSLock                             条件锁升级版，带状态标记                       可以根据条件值加锁和解锁                                       状态管理复杂，容易写错                       多状态同步、状态机式线程控制
 */
extension NSLocking {
    /// 在锁保护下执行闭包
    @discardableResult
    func synchronized<T>(_ block: () throws -> T) rethrows -> T {
        return try withLock(block)
    }
}

/// 加锁
@discardableResult
public func synchronized<T>(_ queue: DispatchQueue, _ block: () throws -> T) rethrows -> T {
    return try queue.sync {
        try block()
    }
}

/// 加锁
@discardableResult
public func synchronized<T>(_ object: NSObject, _ block: () throws -> T) rethrows -> T {
    return try object.synchronized(block)
}

nonisolated(unsafe) var _typeLockDict = ConcurrentDictionary<ObjectIdentifier, NSLocking>()

/// 类类型的枷锁
/// - Parameters:
///   - type: 类类型
///   - block: 锁块
/// - Throws: 异常
/// - Returns: 返回值
@discardableResult
public func synchronized<T>(_ type: Any.Type, _ block: () throws -> T) rethrows -> T {
    let id = ObjectIdentifier(type)
    if let lock = _typeLockDict[id] {
        return try lock.synchronized(block)
    } else {
        let lock = NSRecursiveLock()
        _typeLockDict[id] = lock
        return try lock.synchronized(block)
    }
}
