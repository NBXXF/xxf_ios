//
//  Keychain.swift
//  xxf_ios
//
//  Created by xxf on 7/22.
//

import Foundation
import Security

/// 钥匙串可访问性级别
public enum Accessibility {
    case whenUnlocked
    case whenUnlockedThisDeviceOnly
    case afterFirstUnlock
    case afterFirstUnlockThisDeviceOnly
}

public class Keychain {
    private let nativeKeychain: NativeKeychain

    /// 初始化方法
    /// - Parameters:
    ///   - identifier: 钥匙串标识符
    ///   - accessibility: 可访问性级别
    public init(identifier: String, accessibility: Accessibility = .whenUnlocked) throws {
        guard !identifier.isEmpty else {
            throw KeychainError.invalidIdentifier(identifier)
        }

        let nativeAccessibility: XXFKeychainAccessibility
        switch accessibility {
            case .whenUnlocked:
                nativeAccessibility = .whenUnlocked
            case .whenUnlockedThisDeviceOnly:
                nativeAccessibility = .whenUnlockedThisDeviceOnly
            case .afterFirstUnlock:
                nativeAccessibility = .afterFirstUnlock
            case .afterFirstUnlockThisDeviceOnly:
                nativeAccessibility = .afterFirstUnlockThisDeviceOnly
            default:
                nativeAccessibility = .whenUnlocked
        }

        nativeKeychain = NativeKeychain(service: identifier, accessibility: nativeAccessibility)
    }

    // MARK: - String 存取

    /// 存储字符串
    /// - Parameters:
    ///   - string: 要存储的字符串
    ///   - key: 存储键
    public func setString(_ string: String, forKey key: String) throws {
        try nativeKeychain.setString(string, forKey: key)
    }

    /// 获取字符串
    /// - Parameter key: 存储键
    /// - Returns: 存储的字符串，如果不存在则返回 nil
    public func string(forKey key: String) throws -> String? {
        return try nativeKeychain.getString(forKey: key)
    }

    // MARK: - Data 存取

    /// 存储数据
    /// - Parameters:
    ///   - object: 要存储的数据
    ///   - key: 存储键
    public func setObject(_ object: Data, forKey key: String) throws {
        try nativeKeychain.setData(object, forKey: key)
    }

    /// 获取数据
    /// - Parameter key: 存储键
    /// - Returns: 存储的数据，如果不存在则返回 nil
    public func object(forKey key: String) throws -> Data? {
        return try nativeKeychain.getData(forKey: key)
    }

    // MARK: - Codable 存取

    /// 设置可编码对象
    /// - Parameters:
    ///   - object: 要存储的可编码对象
    ///   - key: 存储键
    public func setCodable<T: Codable>(_ object: T, forKey key: String) throws {
        try nativeKeychain.setCodable(object, forKey: key)
    }

    /// 获取可编码对象
    /// - Parameters:
    ///   - key: 存储键
    ///   - type: 对象类型
    /// - Returns: 存储的对象，如果不存在则返回 nil
    public func getCodable<T: Codable>(forKey key: String, as type: T.Type) throws -> T? {
        return try nativeKeychain.getCodable(forKey: key, as: type)
    }

    // MARK: - 删除操作

    /// 删除指定键的项目
    /// - Parameter key: 要删除的键
    public func removeObject(forKey key: String) throws {
        try nativeKeychain.remove(forKey: key)
    }

    /// 检查是否包含指定键
    /// - Parameter key: 要检查的键
    /// - Returns: 如果存在返回 true，否则返回 false
    public func containsObject(forKey key: String) throws -> Bool {
        return nativeKeychain.contains(key: key)
    }

    /// 删除所有项目
    public func removeAllObjects() throws {
        try nativeKeychain.removeAll()
    }
}
