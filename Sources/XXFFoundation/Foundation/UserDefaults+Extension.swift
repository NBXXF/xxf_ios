//
//  UserDefaults+Extension.swift
//  xxf_ios
//  key-value拓展
//  Created by xxf on 6/26.
//
import Foundation

public extension UserDefaults {
    /// 清空指定域（或标准域）下所有键值
    /// - Parameter suiteName: 传入 nil 则清空标准 UserDefaults；否则清空对应 suiteName
    static func clearAll(suiteName: String? = nil) {
        let defaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard

        // 1. 移除指定域
        if let domain = suiteName ?? Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: domain)
        }
        // 2. 再补删残留键
        for key in defaults.dictionaryRepresentation().keys {
            defaults.removeObject(forKey: key)
        }
        // 3. 同步
        defaults.synchronize()
    }

    /// 清空当前实例的所有 UserDefaults 键值
    /// - 兼容 iOS、macOS（包括非沙盒）
    func clearAll() {
        // 1. 在 iOS 或沙盒 macOS 下，先移除所有持久化域
//        #if !os(macOS)
//            for domain in persistentDomainNames() {
//                removePersistentDomain(forName: domain)
//            }
//        #endif

        // 2. 遍历删除所有残留键值
        for key in dictionaryRepresentation().keys {
            removeObject(forKey: key)
        }

        // 3. 可选：立即同步（现代系统会自动同步，此步可省略）
        synchronize()
    }
}
