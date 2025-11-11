//
//  SharedKeychain.swift
//  xxf_ios
//  钥匙串 多app共享版本
//  Created by xxf on 7/22.
//

import Foundation

/// 支持 App Group 共享钥匙串的 Keychain 子类
public final class SharedKeychain: Keychain {
    public init(appGroupId: String,
                appIDPrefix: String? = nil, // macOS 用的 App ID Prefix，iOS 可忽略
                identifier: String = Bundle.main.bundleIdentifier ?? "default.identifier",
                accessibility: Accessibility = .whenUnlocked) throws
    {
        // 构建共享组标识符
        let sharedIdentifier: String
        #if os(macOS)
            guard let prefix = appIDPrefix else {
                throw KeychainError.invalidAppGroupId("macOS requires App ID Prefix")
            }
            sharedIdentifier = "\(prefix).\(appGroupId).\(identifier)"
        #else
            sharedIdentifier = "group.\(appGroupId).\(identifier)"
        #endif

        // 调用父类初始化方法
        try super.init(identifier: sharedIdentifier, accessibility: accessibility)
    }
}
