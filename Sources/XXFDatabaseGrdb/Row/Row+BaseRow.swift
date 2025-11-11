//
//  Row+BaseRow.swift
//  xxf_ios
//
//  Created by xxf on 6/21.
//
import GRDB
import XXFDatabase

extension Row: BaseRow {
    public func value<T>(forColumn column: String) -> T? {
        return cast(self[column], to: T.self)
    }

    public subscript<T>(column: String) -> T? {
        return value(forColumn: column)
    }

    /// 类型安全的转换，解决 Int <-> Int64 兼容问题
    private func cast<T>(_ value: DatabaseValueConvertible?, to _: T.Type) -> T? {
        guard let v = value else { return nil }

        // GRDB 已经把 SQLite INTEGER 转成 Int64
        if T.self == Int.self, let int64 = v as? Int64 {
            return Int(exactly: int64) as? T
        }

        // 其它情况直接尝试转换
        return v as? T
    }
}
