//
//  UUID+Extension.swift
//  xxf_ios
//  增加uuid拓展
//  Created by trl on 6/19.
//

import Foundation

// MARK: - UUID 扩展

public extension UUID {
    /// 返回 UUID 的 32 位字符串（无中划线）
    var string32: String {
        return uuidString.replacingOccurrences(of: "-", with: "")
    }
}

// MARK: - 快捷访问属性（全局函数）

/// ⚠️ 已废弃：请使用 `randomUUIDString36` 或 `randomUUIDString32`
@available(*, deprecated, renamed: "randomUUIDString36", message: "请用 randomUUIDString36 或者 randomUUIDString32")
public func randomUUIDString() -> String {
    return UUID().uuidString
}

/// 原始 36 位 UUID 字符串（带中划线）
public func randomUUIDString36() -> String {
    return UUID().uuidString
}

/// 去除中划线的 32 位 UUID 字符串
public func randomUUIDString32() -> String {
    return UUID().string32
}
