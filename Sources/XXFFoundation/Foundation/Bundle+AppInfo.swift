
//
//  Bundle+AppInfo.swift
//  YourProject
//  应用相关信息
//  Created by xxf on 07/20.
//

import Foundation

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

public extension Bundle {
    // MARK: - App 基本信息

    /// 显示名称（优先 DisplayName，其次 Name）
    var displayName: String {
        return info("CFBundleDisplayName")
            ?? info("CFBundleName")
            ?? "Unknown App Name"
    }

    /// App 标识符（com.example.app）
    var identifier: String {
        return bundleIdentifier ?? "Unknown Bundle ID"
    }

    /// App 版本号（CFBundleShortVersionString）
    var version: String {
        return info("CFBundleShortVersionString") ?? "0.0"
    }

    /// App 构建号（CFBundleVersion）
    var buildNumber: String {
        return info("CFBundleVersion") ?? "0"
    }

    /// 完整版本信息 v1.0 (42)
    var fullVersion: String {
        return "v\(version) (\(buildNumber))"
    }

    /// 可执行文件名
    var executableName: String {
        return info("CFBundleExecutable") ?? "Unknown"
    }

    /// 部署的最低系统版本
    var minimumOSVersion: String? {
        return info("MinimumOSVersion")
    }

    /// 主类（如 UIApplication 或 NSApplication 子类）
    var principalClassName: String? {
        return info("NSPrincipalClass")
    }

    // MARK: - 环境状态

    /// 是否为 Debug 构建
    var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    /// 是否为 Release 构建
    var isRelease: Bool {
        return !isDebug
    }

    /// 是否通过 TestFlight 安装
    var isTestFlight: Bool {
        guard let receiptURL = appStoreReceiptURL else { return false }
        return receiptURL.lastPathComponent == "sandboxReceipt"
    }

    /// 是否通过 App Store 安装
    var isAppStore: Bool {
        guard let receiptURL = appStoreReceiptURL else { return false }
        return receiptURL.lastPathComponent == "receipt"
    }

    /// 是否为 App Extension
    var isAppExtension: Bool {
        return bundlePath.hasSuffix(".appex")
    }

    /// 是否为 Mac Catalyst 模式
    var isMacCatalystApp: Bool {
        #if targetEnvironment(macCatalyst)
            return true
        #else
            return false
        #endif
    }

    /// 是否运行于模拟器
    var isRunningOnSimulator: Bool {
        #if targetEnvironment(simulator)
            return true
        #else
            return false
        #endif
    }

    // MARK: - 权限用途说明（Info.plist）

    /// 常见权限用途说明（如麦克风、定位、相机等）
    var permissionDescriptions: [String: String] {
        Self.knownPrivacyKeys.reduce(into: [:]) { result, key in
            if let desc: String = info(key) {
                result[key] = desc
            }
        }
    }

    /// 常见权限字段键名
    private static let knownPrivacyKeys: [String] = [
        "NSCameraUsageDescription",
        "NSMicrophoneUsageDescription",
        "NSPhotoLibraryUsageDescription",
        "NSPhotoLibraryAddUsageDescription",
        "NSLocationWhenInUseUsageDescription",
        "NSLocationAlwaysUsageDescription",
        "NSContactsUsageDescription",
        "NSCalendarsUsageDescription",
        "NSRemindersUsageDescription",
        "NSMotionUsageDescription",
        "NSHealthShareUsageDescription",
        "NSHealthUpdateUsageDescription",
        "NSUserTrackingUsageDescription",
        "NSBluetoothAlwaysUsageDescription",
        "NSBluetoothPeripheralUsageDescription",
        "NSFaceIDUsageDescription"
    ]

    // MARK: - 配置项（Info.plist）

    /// 支持的 URL Schemes（如 wechat, alipay）
    var urlSchemes: [String] {
        guard let types = info("CFBundleURLTypes") as [[String: Any]]? else { return [] }
        return types.compactMap { $0["CFBundleURLSchemes"] as? [String] }.flatMap { $0 }
    }

    /// 支持的文档类型（如 com.adobe.pdf）
    var documentTypes: [String] {
        guard let types = info("CFBundleDocumentTypes") as [[String: Any]]? else { return [] }
        return types.compactMap { $0["LSItemContentTypes"] as? [String] }.flatMap { $0 }
    }

    /// 自定义导出的 UTI 类型（Uniform Type Identifier）
    var exportedUTIs: [String] {
        guard let exports = info("UTExportedTypeDeclarations") as [[String: Any]]? else { return [] }
        return exports.compactMap { $0["UTTypeIdentifier"] as? String }
    }

    /// App 图标文件名称列表（包含不同尺寸）
    var iconFileNames: [String] {
        guard let icons = info("CFBundleIcons") as [String: Any]?,
              let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let files = primary["CFBundleIconFiles"] as? [String]
        else {
            return []
        }
        return files
    }

    /// 默认语言标识（如 zh-Hans, en）
    var preferredLocalization: String {
        return preferredLocalizations.first ?? localizations.first ?? "en"
    }

    /// App Transport Security 是否启用（默认启用）
    var isAppTransportSecurityEnabled: Bool {
        guard let ats: [String: Any] = info("NSAppTransportSecurity") else {
            return true
        }
        return !(ats["NSAllowsArbitraryLoads"] as? Bool ?? false)
    }

    /// 开发团队 Team ID（仅在部分环境下可获取）
    var teamIdentifier: String? {
        return (self as AnyObject).value(forKey: "teamIdentifier") as? String
    }

    // MARK: - 工具方法

    /// 从 Info.plist 获取指定键对应的值（泛型）
    private func info<T>(_ key: String) -> T? {
        return object(forInfoDictionaryKey: key) as? T
    }
}
