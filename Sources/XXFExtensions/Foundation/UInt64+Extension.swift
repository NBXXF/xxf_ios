//
//  UInt64+Extension.swift
//  xxf_ios
//
//  Created by xxf on /6/24.
//

import Foundation

public extension UInt64 {
    /// 尝试将 UInt64 转换为 Int,转换失败用.max
    var intValue: Int {
        return Int(exactly: self) ?? Int.max
    }

    // 越界就返回nil
    var intValueOrNil: Int? {
        return Int(exactly: self)
    }
}
