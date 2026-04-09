//
//  Date+Ext.swift
//  xxf_ios
//
//  Created by xxf on 2023/3/26.
//

public extension Date {
    /// 当前 Date 对应的毫秒级时间戳 (Int64)
    var timestampMillis: Int64 {
        Int64(timeIntervalSince1970 * 1000)
    }
}
