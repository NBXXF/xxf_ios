//
//  String+Sql.swift
//  xxf_ios
//  sql通配符问题
//  Created by xxf on 7/12.
//

import Foundation
import GRDB

// MARK: - 字符串转义扩展

public extension String {
    /// 转义 SQL LIKE 中的特殊字符：%, _, 和 escape 字符本身
    /// - Parameter escapeChar: 转义符（默认为 `\`）
    /// - Returns: 转义后的字符串
    func sqlEscapedForLike(escapeChar: String = "\\") -> String {
        replacingOccurrences(of: escapeChar, with: escapeChar + escapeChar)
            .replacingOccurrences(of: "%", with: escapeChar + "%")
            .replacingOccurrences(of: "_", with: escapeChar + "_")
    }
}
