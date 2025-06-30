//
//  NSMetadataProtocol+Query.swift
//  xxf_ios
//
//  Created by xxf on 6/17.
//

import Foundation

public extension NSMetadataProtocol {
    /// 生成用于 xattr 的带 bundleId 命名空间的 Key
    /// - Parameter key: 原始 key（如 "meta"）
    /// - Returns: 完整带命名空间的 key（如 "com.example.myapp.meta"）
    static func attrNamespacedKey(_ key: String) -> String {
        /// 单元测试，Playground 等场景下面bundleIdentifier 可能为空
        let bundleId = Bundle.main.bundleIdentifier ?? "com.unknown.app"
        if key.hasPrefix(bundleId + ".") {
            return key
        }
        return "\(bundleId).\(key)"
    }
}
