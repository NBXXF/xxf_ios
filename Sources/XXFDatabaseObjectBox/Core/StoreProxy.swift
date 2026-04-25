//
//  StoreProxy.swift
//  xxf_ios
//  Store 的代理封装，增加禁止主线程访问的判断，并提供读写事务辅助方法
//  Created by xxf on 4/25.
//
import Foundation
import ObjectBox
import XXFFoundation

/// ObjectBox `Store` 的代理封装
///
/// - 允许禁止主线程访问（与 GRDB `DatabaseProxy` 对齐，避免 I/O 阻塞 UI 线程）
/// - 封装读/写事务辅助方法，供上层 DAO 使用
public final class StoreProxy {
    public let store: Store
    private let allowMainThread: Bool

    public init(store: Store, allowMainThread: Bool = false) {
        self.store = store
        self.allowMainThread = allowMainThread
    }

    /// 返回指定实体类型的 `Box`（加上主线程检查）
    public func box<E>(for entityType: E.Type = E.self) -> Box<E>
        where E: EntityInspectable & __EntityRelatable
    {
        if !allowMainThread {
            requireChildThread()
        }
        return store.box(for: entityType)
    }

    /// 只读事务：支持返回值
    public func read<T>(_ block: (Store) throws -> T) throws -> T {
        if !allowMainThread {
            requireChildThread()
        }
        return try store.runInReadOnlyTransaction {
            try block(store)
        }
    }

    /// 读写事务：支持返回值
    public func write<T>(_ block: (Store) throws -> T) throws -> T {
        if !allowMainThread {
            requireChildThread()
        }
        return try store.runInTransaction {
            try block(store)
        }
    }
}
