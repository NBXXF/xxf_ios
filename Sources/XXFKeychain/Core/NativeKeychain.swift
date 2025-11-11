//
//  NativeKeychain.swift
//  xxf_ios
//  原生钥匙串实现，不依赖 Valet 库
//  Created by xxf on 7/22.
//

import Foundation
import Security

/// 原生 Keychain 访问级别
public enum XXFKeychainAccessibility {
    case whenUnlocked
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlock
    case afterFirstUnlockThisDeviceOnly

    var secAttrAccessible: CFString {
        switch self {
        case .whenUnlocked:
            return kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly:
            return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlock:
            return kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly:
            return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        }
    }
}

/// 原生 Keychain 实现类
public class NativeKeychain {
    private let service: String
    private let accessibility: XXFKeychainAccessibility

    /// 初始化方法
    /// - Parameters:
    ///   - service: 服务标识符
    ///   - accessibility: 可访问性级别
    public init(service: String, accessibility: XXFKeychainAccessibility = .whenUnlocked) {
        self.service = service
        self.accessibility = accessibility
    }

    // MARK: - String 存取

    /// 设置字符串
    /// - Parameters:
    ///   - value: 要存储的字符串值
    ///   - key: 存储键
    /// - Throws: KeychainError
    public func setString(_ value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else {
            throw KeychainError.invalidIdentifier("Failed to convert string to data")
        }
        try setData(data, forKey: key)
    }

    /// 获取字符串
    /// - Parameter key: 存储键
    /// - Returns: 存储的字符串值，如果不存在则返回 nil
    /// - Throws: KeychainError
    public func getString(forKey key: String) throws -> String? {
        guard let data = try getData(forKey: key) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Data 存取

    /// 设置数据
    /// - Parameters:
    ///   - data: 要存储的数据
    ///   - key: 存储键
    /// - Throws: KeychainError
    public func setData(_ data: Data, forKey key: String) throws {
        // 先尝试更新现有项目
        let updateQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]

        let updateAttributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility.secAttrAccessible,
        ]

        let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            // 项目不存在，创建新项目
            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessible as String: accessibility.secAttrAccessible,
            ]

            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.invalidIdentifier("Failed to add keychain item: \(addStatus)")
            }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.invalidIdentifier("Failed to update keychain item: \(updateStatus)")
        }
    }

    /// 获取数据
    /// - Parameter key: 存储键
    /// - Returns: 存储的数据，如果不存在则返回 nil
    /// - Throws: KeychainError
    public func getData(forKey key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.invalidIdentifier("Failed to retrieve keychain item: \(status)")
        }

        return result as? Data
    }

    // MARK: - Codable 存取

    /// 设置可编码对象
    /// - Parameters:
    ///   - object: 要存储的可编码对象
    ///   - key: 存储键
    /// - Throws: KeychainError
    public func setCodable<T: Codable>(_ object: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(object)
        try setData(data, forKey: key)
    }

    /// 获取可编码对象
    /// - Parameters:
    ///   - key: 存储键
    ///   - type: 对象类型
    /// - Returns: 存储的对象，如果不存在则返回 nil
    /// - Throws: KeychainError
    public func getCodable<T: Codable>(forKey key: String, as type: T.Type) throws -> T? {
        guard let data = try getData(forKey: key) else {
            return nil
        }
        return try JSONDecoder().decode(type, from: data)
    }

    // MARK: - 删除操作

    /// 删除指定键的项目
    /// - Parameter key: 要删除的键
    /// - Throws: KeychainError
    public func remove(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.invalidIdentifier("Failed to delete keychain item: \(status)")
        }
    }

    /// 检查是否包含指定键
    /// - Parameter key: 要检查的键
    /// - Returns: 如果存在返回 true，否则返回 false
    public func contains(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// 删除所有项目
    /// - Throws: KeychainError
    public func removeAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.invalidIdentifier("Failed to delete all keychain items: \(status)")
        }
    }
}
