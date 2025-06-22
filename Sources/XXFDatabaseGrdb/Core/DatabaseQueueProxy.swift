//
//  DatabaseQueueProxy.swift
//  xxf_ios
//
//  Created by trl on 6/22.
//
import Foundation
import GRDB

/// DatabaseQueue 的代理封装，增加禁止主线程访问的判断
public final class DatabaseQueueProxy {
    private let dbQueue: DatabaseQueue
    private let allowMainThread: Bool

    init(dbQueue: DatabaseQueue, allowMainThread: Bool = false) {
        self.dbQueue = dbQueue
        self.allowMainThread = allowMainThread
    }

    /// 读取，禁止主线程调用（除非 allowMainThread == true）
    public func read<T>(_ block: (Database) throws -> T) throws -> T {
        #if DEBUG
            if !allowMainThread, Thread.isMainThread {
                assertionFailure("Database read is not allowed on main thread")
            }
        #endif
        return try dbQueue.read(block)
    }

    /// 写入，禁止主线程调用（除非 allowMainThread == true）
    public func write<T>(_ block: (Database) throws -> T) throws -> T {
        #if DEBUG
            if !allowMainThread, Thread.isMainThread {
                assertionFailure("Database write is not allowed on main thread")
            }
        #endif
        return try dbQueue.write(block)
    }
}
