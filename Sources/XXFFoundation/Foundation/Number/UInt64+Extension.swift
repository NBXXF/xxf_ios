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

    var int64Value: Int64 {
        return int64ValueOrNil ?? Int64.max
    }

    var int64ValueOrNil: Int64? {
        // 范围检查：UInt64 必须 ≤ Int64.max（避免溢出）
        // 注意：Int64.max 是 9223372036854775807，其 UInt64 等价值可直接比较
        guard self <= UInt64(Int64.max) else {
            return nil
        }
        // 直接转换（原生类型操作，无额外开销）
        return Int64(self)
    }
}
