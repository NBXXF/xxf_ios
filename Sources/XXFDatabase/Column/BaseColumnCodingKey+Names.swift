//
//  BaseColumnCodingKey+Names.swift
//  xxf_ios
//
//  Created by xxf on 6/21.
//

public extension BaseColumnCodingKey {
    /// 返回数据库列名（即 rawValue）
    var columnName: String {
        return stringValue
    }

    /// 全部列名
    static var allColumnNames: [String] {
        return allCases.map(\.columnName)
    }
}
