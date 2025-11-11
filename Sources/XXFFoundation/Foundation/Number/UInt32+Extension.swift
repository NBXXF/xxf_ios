//
//  UInt32+Extension.swift
//  xxf_ios
//
//  Created by xxf on /6/24.
//

public extension UInt32 {
    /// 将 UInt32 安全转换为 Int，转换为 Int,转换失败用.max
    var intValue: Int {
        return Int(exactly: self) ?? Int.max
    }

    // 越界就返回nil
    var intValueOrNil: Int? {
        return Int(exactly: self)
    }
}
