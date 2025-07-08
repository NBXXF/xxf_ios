//
//  Dictionary+Extension.swift
//  xxf_ios
//  字典的拓展
//  Created by xxf on 7/8.
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
}
