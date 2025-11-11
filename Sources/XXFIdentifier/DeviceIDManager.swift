//
//  DeviceIDManager.swift
//  xxf_ios
//
//  管理应用/设备唯一标识的工具类
//  Created by xxf on 7/22.
//

import Foundation
import XXFKeychain

#if os(macOS) || targetEnvironment(macCatalyst)
import IOKit
#endif

#if os(iOS)
import UIKit
#endif

@MainActor
public enum DeviceIDManager {
    private nonisolated(unsafe) static var cachedID: String?

    // 使用你写的 Keychain 封装类
    private nonisolated(unsafe) static let keychain: Keychain = {
        do {
            return try Keychain(
                identifier: Bundle.main.bundleIdentifier ?? "com.xxf.unique",
                accessibility: .whenUnlockedThisDeviceOnly
            )
        } catch {
            fatalError("Failed to initialize Keychain: \(error)")
        }
    }()

    private static let keychainKey = "app_device_id"

    public static func getDeviceID() -> String {
        if let id = cachedID {
            return id
        }
        let id = loadOrCreateID()
        cachedID = id
        return id
    }

    private static func loadOrCreateID() -> String {
        // 1. 从 Keychain 读取
        if let id = readFromCache() {
            return id
        }

        // 平台相关：macOS/Catalyst 使用 IOKit 常量获取硬件 UUID/序列号；iOS 使用 identifierForVendor
        #if targetEnvironment(macCatalyst) || os(macOS)
        // 2. 硬件级 UUID (macOS / Catalyst)
        if let uuid = ioPlatformProperty(kIOPlatformUUIDKey as CFString), isValidID(uuid) {
            writeToCache(uuid)
            return uuid
        }

        // 3. 系列号 (macOS / Catalyst)
        if let serial = ioPlatformProperty(kIOPlatformSerialNumberKey as CFString), isValidID(serial) {
            writeToCache(serial)
            return serial
        }
        #elseif os(iOS)
        // iOS: 使用 identifierForVendor 作为硬件级近似 ID（系统允许的接口）
        if let idfv = UIDevice.current.identifierForVendor?.uuidString, isValidID(idfv) {
            writeToCache(idfv)
            return idfv
        }
        #endif

        // 4. 随机 UUID
        let randomID = UUID().uuidString
        writeToCache(randomID)
        return randomID
    }

    private static func readFromCache() -> String? {
        if let id = try? keychain.string(forKey: keychainKey), isValidID(id) {
            return id
        }
        if let id = UserDefaults.standard.string(forKey: keychainKey), isValidID(id) {
            /// 弥补没有写入到钥匙串
            writeToCache(id)
            return id
        }
        return nil
    }

    private static func writeToCache(_ serial: String) {
        do {
            try keychain.setString(serial, forKey: keychainKey)
        } catch {
            NSLog("⚠️ DeviceIDManager: Failed to save ID to Keychain: \(error), fallback to UserDefaults")
            UserDefaults.standard.set(serial, forKey: keychainKey)
        }
    }

    /// 判断传入的设备 ID 是否为有效值，排除各种常见的垃圾、无效或默认值。
    ///
    /// 筛选规则包括：
    /// 1. 非空，且不为 "null"（大小写不敏感）
    /// 2. 长度必须大于 5
    /// 3. 不能包含常见的无效关键字，如 "unknown"、"default"、"undefined" 等
    /// 4. 不允许全部由重复字符组成（例如 "aaaaaa", "000000"）
    /// 5. 排除常见顺序字符（如 "123456", "abcdef"），支持子串匹配
    /// 6. 排除仅由单一字符类型组成（全数字或全字母）
    /// 7. 排除包含非 ASCII 字符（如乱码）
    ///
    /// - Parameter id: 待校验的设备 ID
    /// - Returns: 如果是合法设备 ID，则返回 true；否则返回 false
    private static func isValidID(_ id: String?) -> Bool {
        guard let id = id?.trimmingCharacters(in: .whitespacesAndNewlines),
              !id.isEmpty,
              id.lowercased() != "null",
              id.count > 5
        else {
            return false
        }

        let lowercased = id.lowercased()

        // 黑名单关键词
        let badKeywords = ["unknown", "default", "undefined", "000000", "ffffff"]
        if badKeywords.contains(where: { lowercased.contains($0) }) {
            return false
        }

        // 重复字符
        if Set(id).count == 1 {
            return false
        }

        // 顺序子串检测
        let sequentialPatterns = [
            "0123456789",
            "1234567890",
            "abcdefghijklmnopqrstuvwxyz",
            String("abcdefghijklmnopqrstuvwxyz".reversed()),
        ]
        for pattern in sequentialPatterns {
            for i in 0 ... (pattern.count - 6) {
                let sub = pattern.dropFirst(i).prefix(6)
                if lowercased.contains(sub) {
                    return false
                }
            }
        }

        // 全数字或全字母
        if id.range(of: "^[0-9]+$", options: .regularExpression) != nil ||
            id.range(of: "^[a-zA-Z]+$", options: .regularExpression) != nil
        {
            return false
        }

        // 非 ASCII 字符（可选）
        if !id.canBeConverted(to: .ascii) {
            return false
        }

        return true
    }

    private static func ioPlatformProperty(_ key: CFString) -> String? {
        #if targetEnvironment(macCatalyst) || os(macOS)
        // macOS / Catalyst: 使用原始 IOKit
        guard NSClassFromString("IOService") != nil else { return nil }
        let service = IOServiceGetMatchingService(kIOMainPortDefault,
                                                  IOServiceMatching("IOPlatformExpertDevice"))
        defer { IOObjectRelease(service) }
        guard service != 0,
              let cfValue = IORegistryEntryCreateCFProperty(service,
                                                            key,
                                                            kCFAllocatorDefault, 0)?
              .takeUnretainedValue(),
              let value = cfValue as? String,
              !value.isEmpty
        else {
            return nil
        }
        return value
        #else
        // 其他平台不支持 IOKit
        return nil
        #endif
    }

}
