//
//  NSObject+Lock.swift
//  xxf_ios
//  内置到关联对象上面的可重入锁,性能差距不是很大
//  Created by xxf on 8/22.
//

import Foundation

private nonisolated(unsafe) var syncLockKey: UInt8 = 0
extension NSObject {
    /// 每个对象挂载一个独立的 NSRecursiveLock
    private var _syncLock: NSRecursiveLock {
        if let lock = objc_getAssociatedObject(self, &syncLockKey) as? NSRecursiveLock {
            return lock
        }
        let lock = NSRecursiveLock()
        objc_setAssociatedObject(self, &syncLockKey, lock, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return lock
    }

    /// 通用同步方法
    func synchronized<T>(_ block: () throws -> T) rethrows -> T {
        if let locking = self as? NSLocking {
            return try locking.withLock(block)
        } else {
            return try _syncLock.withLock(block)
        }
    }
}
