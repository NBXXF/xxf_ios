//
//  BaseColumnCodingKey+Extension.swift
//  xxf_ios
//
//  Created by xxf on 6/21.
//

public extension BaseColumnCodingKey {
    /// 返回数据库列名（即 rawValue）
    var name: String {
        return rawValue
    }

    /// 全部列名
    static var allNames: [String] {
        let cache = ColumnNameCache.columns(for: Self.self)
        #if DEBUG
            return Array(cache) // Debug模式防止误改
        #else
            return cache // Release 模式性能优先
        #endif
    }
}
