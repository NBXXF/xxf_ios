//
//  Column+Extensions.swift
//  xxf_ios
//  快速映射列转换成grdb
//  Created by xxf on 6/21.
//
import GRDB
import XXFDatabase

public extension BaseColumnCodingKey {
    /// 返回该 CodingKey 对应的 GRDB Column
    var column: Column {
        Column(name)
    }

    /// 缓存后的所有 Column 数组
    static var allColumns: [Column] {
        let cache = ColumnCache.columns(for: Self.self)
        #if DEBUG
            return Array(cache) // Debug模式防止误改
        #else
            return cache // Release 模式性能优先
        #endif
    }
}
