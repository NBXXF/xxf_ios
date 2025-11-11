//
//  DatabaseQueueProxy.swift
//  xxf_ios
//
//  Created by xxf on 6/05.
//
import Foundation
import GRDB
import XXFFoundation

/// Database的代理封装，增加禁止主线程访问的判断
public final class DatabaseProxy {
    private let database: DatabaseReader & DatabaseWriter
    private let allowMainThread: Bool

    init(database: DatabaseReader & DatabaseWriter, allowMainThread: Bool = false) {
        self.database = database
        self.allowMainThread = allowMainThread
    }

    /// 读取，禁止主线程调用（除非 allowMainThread == true）
    public func read<T>(_ block: (Database) throws -> T) throws -> T {
        if !allowMainThread {
            requireChildThread()
        }
        return try database.read(block)
    }

    /// 写入，禁止主线程调用（除非 allowMainThread == true）
    public func write<T>(_ block: (Database) throws -> T) throws -> T {
        if !allowMainThread {
            requireChildThread()
        }
        return try database.write(block)
    }
}
