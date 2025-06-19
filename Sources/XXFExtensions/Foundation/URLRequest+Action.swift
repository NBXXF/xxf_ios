//
//  URLRequest+Action.swift
//  xxf_ios
//
//  Created by trl on 6/18.
//
import Foundation

public extension URLRequest {
    /// request.addValue("xxx", forHTTPHeaderField: "Authorization") 如果已经存在 Authorization，它会追加成多个值（合并），除非你用：
    /// request.setValue("xxx", forHTTPHeaderField: "Authorization") 替换已有值。
    /// 这个方法 是对应的key不存在,才会插入
    mutating func setValueIfAbsent(_ value: String?, forHTTPHeaderField field: String) {
        if self.value(forHTTPHeaderField: field) == nil {
            setValue(value, forHTTPHeaderField: field)
        }
    }

    mutating func putValueIfAbsent(_ value: String?, forHTTPHeaderField field: String) {
        setValueIfAbsent(value, forHTTPHeaderField: field)
    }
}
