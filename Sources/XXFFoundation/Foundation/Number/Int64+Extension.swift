//
//  Int64+Extension.swift
//  xxf_ios
//
//  Created by xxf on 2025/9/29.
//

public extension Int64 {
    /// 安全转换为 Int，转换为 Int,转换失败用.max
    var intValue: Int {
        return Int(exactly: self) ?? Int.max
    }

    // 越界就返回nil
    var intValueOrNil: Int? {
        return Int(exactly: self)
    }
}
