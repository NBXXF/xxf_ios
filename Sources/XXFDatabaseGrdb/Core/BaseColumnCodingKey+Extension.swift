//
//  Column+Extensions.swift
//  xxf_ios
//  快速映射列转换成grdb
//  Created by trl on 6/21.
//
import GRDB
import XXFDatabase

public extension BaseColumnCodingKey {
    /// 返回该 CodingKey 对应的 GRDB Column
    var column: Column {
        Column(rawValue)
    }

    /// 缓存后的所有 Column 数组
    static var allColumns: [Column] {
        ColumnCache.columns(for: Self.self)
    }
}
