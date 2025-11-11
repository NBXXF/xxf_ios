//
//  Dictionary+XXFExtension.swift
//  xxf_ios
//
//  Created by xxf on 7/25.
//

public extension Dictionary {
    /// 全部key
    var keyArray: [Key] {
        return Array(keys)
    }

    /// 全部value
    var valueArray: [Value] {
        return Array(values)
    }

    /// 如果 key 不存在才设置 value
    @discardableResult
    mutating func putIfAbsent(_ key: Key, _ value: @autoclosure () -> Value) -> Bool {
        if self[key] == nil {
            self[key] = value()
            return true
        }
        return false
    }
}
