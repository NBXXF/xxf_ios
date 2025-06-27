//
//  Database+BuildInRow.swift
//  xxf_ios
//
//  Created by xxf on 6/25.
//
import XXFDatabase

public extension Database {
    /// 插入内置的记录
    func insertBuiltinRecords<T: BaseEntity & BuiltinTable>(_: T.Type) throws {
        for record in T.builtinRecords {
            try record.insert(self)
        }
    }
}
