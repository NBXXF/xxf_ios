//
//  Int+Extension.swift
//  xxf_ios
//
//  Created by xxf on 2026/9/29.
//

public extension Int {
    var uint64ValueOrNil: UInt64? {
        return UInt64(exactly: self)
    }
}
