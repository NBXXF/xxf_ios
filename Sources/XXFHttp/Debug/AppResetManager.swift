////
////  AppResetManager.swift
////  应用重置工具 - 用于开发调试时彻底清理沙盒数据
////
//
//import CoreData
//import Foundation
//import Security
//#if canImport(UIKit)
//import UIKit
//#elseif canImport(AppKit)
//import AppKit
//#endif
//
///// 应用重置管理器 - 仅在 DEBUG 模式下可用
//@MainActor
//public final class AppResetManager {
//    // MARK: - Types
//
//    /// 重置结果
//    public enum ResetResult {
//        case success
//        case partialFailure([ResetError])
//        case cancelled
//    }
//
//    /// 重置错误
//    public struct ResetError: Error, CustomStringConvertible {
//        public let component: ResetComponent
//        public let underlyingError: Error
//
//        public var description: String {
//            "[\(component)] \(underlyingError.localizedDescription)"
//        }
//    }
//
//    /// 重置组件类型
//    public enum ResetComponent: String, CaseIterable, Sendable {
//        case userDefaults = "UserDefaults"
//        case keychain = "Keychain"
//        case fileSystem = "FileSystem"
//        case urlCache = "URLCache"
//        case coreData = "CoreData"
//        case notifications = "Notifications"
//    }
//
//    /// 重置选项
//    public struct Options: OptionSet {
//        public let rawValue: Int
//        public init(rawValue: Int) { self.rawValue = rawValue }
//
//        public nonisolated(unsafe) static let userDefaults = Options(rawValue: 1 << 0)
//        public nonisolated(unsafe) static let keychain = Options(rawValue: 1 << 1)
//        public nonisolated(unsafe) static let documents = Options(rawValue: 1 << 2)
//        public nonisolated(unsafe) static let library = Options(rawValue: 1 << 3)
//        public nonisolated(unsafe) static let caches = Options(rawValue: 1 << 4)
//        public nonisolated(unsafe) static let tmp = Options(rawValue: 1 << 5)
//        public nonisolated(unsafe) static let urlCache = Options(rawValue: 1 << 6)
//        public nonisolated(unsafe) static let coreData = Options(rawValue: 1 << 7)
//        public nonisolated(unsafe) static let notifications = Options(rawValue: 1 << 8)
//
//        public nonisolated(unsafe) static let all: Options = [
//            .userDefaults, .keychain, .documents, .library,
//            .caches, .tmp, .urlCache, .coreData, .notifications
//        ]
//
//        public nonisolated(unsafe) static let safe: Options = [
//            .userDefaults, .documents, .library, .caches, .tmp
//        ]
//    }
//
//    // MARK: - Properties
//
//    public static let shared = AppResetManager()
//
//    /// 是否在执行重置操作（防止并发）
//    private var isResetting = false
//
//    /// 重置进度回调
//    public var onProgress: ((ResetComponent, Bool) -> Void)?
//
//    // MARK: - Initialization
//
//    private init() {}
//
//    // MARK: - Public Methods
//
//    /// 执行应用重置
//    /// - Parameters:
//    ///   - options: 重置选项，默认 .all（彻底重置）
//    ///   - confirmBlock: 确认回调（用于显示确认弹窗），返回 true 继续，false 取消
//    ///   - completion: 完成回调
//    public func reset(
//        options: Options = .all,
//        confirmBlock: (@MainActor () async -> Bool)? = nil,
//        completion: (@MainActor (ResetResult) -> Void)? = nil
//    ) {
//        // 防止并发重置
//        guard !isResetting else {
//            completion?(.cancelled)
//            return
//        }
//
//        isResetting = true
//
//        Task.detached { [weak self] in
//            guard let self = self else {
//                return
//            }
//            // 用户确认
//            if let confirm = confirmBlock {
//                let shouldContinue = await confirm()
//                guard shouldContinue else {
//                    await MainActor.run {
//                        self.isResetting = false
//                        completion?(.cancelled)
//                    }
//                    return
//                }
//            }
//
//            var errors: [ResetError] = []
//
//            // 1. 重置 UserDefaults
//            if options.contains(.userDefaults) {
//                do {
//                    try self.resetUserDefaults()
//                    await MainActor.run {
//                        self.onProgress?(.userDefaults, true)
//                    }
//                } catch {
//                    errors.append(ResetError(component: .userDefaults, underlyingError: error))
//                    await MainActor.run {
//                        self.onProgress?(.userDefaults, false)
//                    }
//                }
//            }
//
//            // 2. 重置 Keychain
//            if options.contains(.keychain) {
//                do {
//                    try self.resetKeychain()
//                    await MainActor.run {
//                        self.onProgress?(.keychain, true)
//                    }
//                } catch {
//                    errors.append(ResetError(component: .keychain, underlyingError: error))
//                    await MainActor.run {
//                        self.onProgress?(.keychain, false)
//                    }
//                }
//            }
//
//            // 3. 重置文件系统
//            if options.contains(.documents) || options.contains(.library) ||
//                options.contains(.caches) || options.contains(.tmp)
//            {
//                do {
//                    try self.resetFileSystem(options: options)
//                    await MainActor.run {
//                        self.onProgress?(.fileSystem, true)
//                    }
//                } catch {
//                    errors.append(ResetError(component: .fileSystem, underlyingError: error))
//                    await MainActor.run {
//                        self.onProgress?(.fileSystem, false)
//                    }
//                }
//            }
//
//            // 4. 重置 URLCache
//            if options.contains(.urlCache) {
//                do {
//                    try self.resetURLCache()
//                    await MainActor.run {
//                        self.onProgress?(.urlCache, true)
//                    }
//                } catch {
//                    errors.append(ResetError(component: .urlCache, underlyingError: error))
//                    await MainActor.run {
//                        self.onProgress?(.urlCache, false)
//                    }
//                }
//            }
//
//            // 5. 重置 CoreData
//            if options.contains(.coreData) {
//                do {
//                    try self.resetCoreData()
//                    await MainActor.run {
//                        self.onProgress?(.coreData, true)
//                    }
//                } catch {
//                    errors.append(ResetError(component: .coreData, underlyingError: error))
//                    await MainActor.run {
//                        self.onProgress?(.coreData, false)
//                    }
//                }
//            }
//
//            // 6. 重置通知权限标记
//            if options.contains(.notifications) {
//                do {
//                    try self.resetNotificationSettings()
//                    await MainActor.run {
//                        self.onProgress?(.notifications, true)
//                    }
//                } catch {
//                    errors.append(ResetError(component: .notifications, underlyingError: error))
//                    await MainActor.run {
//                        self.onProgress?(.notifications, false)
//                    }
//                }
//            }
//
//            await MainActor.run {
//                self.isResetting = false
//
//                // 返回结果
//                if errors.isEmpty {
//                    completion?(.success)
//
//                    // 可选：自动重启应用
//                    // restartApp()
//                } else {
//                    completion?(.partialFailure(errors))
//                }
//            }
//        }
//    }
//
//    /// 安全重置（不包含 Keychain 等敏感数据）
//    public func safeReset(
//        confirmBlock: (@MainActor () async -> Bool)? = nil,
//        completion: (@MainActor (ResetResult) -> Void)? = nil
//    ) {
//        reset(options: .safe, confirmBlock: confirmBlock, completion: completion)
//    }
//
//    /// 重启应用（退出到主屏幕，用户需手动重新打开）
//    public func restartApp() {
//        exit(0)
//    }
//}
//
//// MARK: - Private Reset Methods
//
//private extension AppResetManager {
//    /// 重置 UserDefaults
//    func resetUserDefaults() throws {
//        guard let bundleId = Bundle.main.bundleIdentifier else {
//            throw ResetError(component: .userDefaults, underlyingError: NSError(domain: "AppReset", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法获取 bundle identifier"]))
//        }
//
//        // 移除所有数据
//        UserDefaults.standard.removePersistentDomain(forName: bundleId)
//        UserDefaults.standard.synchronize()
//
//        // 额外清理标准 UserDefaults
//        let standardDefaults = UserDefaults.standard
//        for key in standardDefaults.dictionaryRepresentation().keys {
//            standardDefaults.removeObject(forKey: key)
//        }
//        standardDefaults.synchronize()
//
//        print("✅ UserDefaults 已清理")
//    }
//
//    /// 重置 Keychain
//    func resetKeychain() throws {
//        let secItemClasses: [CFString] = [
//            kSecClassGenericPassword,
//            kSecClassInternetPassword,
//            kSecClassCertificate,
//            kSecClassKey,
//            kSecClassIdentity
//        ]
//
//        var totalStatus: OSStatus = errSecSuccess
//
//        for itemClass in secItemClasses {
//            let query: [String: Any] = [
//                kSecClass as String: itemClass,
//                kSecMatchLimit as String: kSecMatchLimitAll
//            ]
//            let status = SecItemDelete(query as CFDictionary)
//            if status != errSecSuccess, status != errSecItemNotFound {
//                totalStatus = status
//            }
//        }
//
//        guard totalStatus == errSecSuccess || totalStatus == errSecItemNotFound else {
//            throw ResetError(component: .keychain, underlyingError: NSError(domain: "AppReset", code: Int(totalStatus), userInfo: [NSLocalizedDescriptionKey: "Keychain 清理失败，状态码: \(totalStatus)"]))
//        }
//
//        print("✅ Keychain 已清理")
//    }
//
//    /// 重置文件系统
//    func resetFileSystem(options: Options) throws {
//        let fileManager = FileManager.default
//
//        var directoriesToClean: [URL] = []
//
//        if options.contains(.documents) {
//            if let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
//                directoriesToClean.append(url)
//            }
//        }
//
//        if options.contains(.library) {
//            if let url = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first {
//                directoriesToClean.append(url)
//            }
//        }
//
//        if options.contains(.caches) {
//            if let url = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
//                directoriesToClean.append(url)
//            }
//        }
//
//        if options.contains(.tmp) {
//            directoriesToClean.append(fileManager.temporaryDirectory)
//        }
//
//        for directory in directoriesToClean {
//            guard fileManager.fileExists(atPath: directory.path) else { continue }
//
//            let contents = try fileManager.contentsOfDirectory(
//                at: directory,
//                includingPropertiesForKeys: nil,
//                options: .skipsHiddenFiles
//            )
//
//            for item in contents {
//                // 跳过系统文件
//                let fileName = item.lastPathComponent
//                if fileName.hasPrefix(".") { continue }
//
//                do {
//                    try fileManager.removeItem(at: item)
//                } catch {
//                    print("⚠️ 删除文件失败: \(item.path), error: \(error)")
//                }
//            }
//        }
//
//        print("✅ 文件系统已清理: \(directoriesToClean.count) 个目录")
//    }
//
//    /// 重置 URLCache
//    func resetURLCache() throws {
//        URLCache.shared.removeAllCachedResponses()
//
//        // 清理磁盘缓存
//        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("URLCache") {
//            try? FileManager.default.removeItem(at: cacheURL)
//        }
//
//        // 重新配置缓存（注意：iOS 上 URLCache.shared 不能重新赋值，只能在初始化时配置）
//        URLCache.shared.removeAllCachedResponses()
//
//        print("✅ URLCache 已清理")
//    }
//
//    /// 重置 CoreData
//    func resetCoreData() throws {
//        // 关闭所有 CoreData 存储
//        NSPersistentStoreCoordinator.removePersistentStores()
//
//        // 清理 CoreData 相关目录
//        let fileManager = FileManager.default
//        let libraryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
//
//        let coreDataPaths = [
//            "Application Support",
//            "CoreData",
//            "Caches"
//        ]
//
//        for path in coreDataPaths {
//            if let url = libraryURL?.appendingPathComponent(path) {
//                try? fileManager.removeItem(at: url)
//            }
//        }
//
//        print("✅ CoreData 存储已清理")
//    }
//
//    /// 重置通知设置标记
//    func resetNotificationSettings() throws {
//        UserDefaults.standard.removeObject(forKey: "hasRequestedNotificationPermission")
//        UserDefaults.standard.synchronize()
//
//        #if canImport(UIKit)
//        // 注意：iOS 无法通过代码重置系统通知权限，只能重置应用内的标记
//        UIApplication.shared.unregisterForRemoteNotifications()
//        #endif
//
//        print("✅ 通知设置标记已重置")
//    }
//}
//
//// MARK: - Helper Extensions
//
//private extension NSPersistentStoreCoordinator {
//    static func removePersistentStores() {
//        // 这是一个占位实现，实际使用时需要传入具体的 coordinator
//        // 建议在 App 中实现具体的 CoreData 重置逻辑
//    }
//}
//
//// MARK: - Usage Example
//
///*
// // 在开发菜单中调用
// AppResetManager.shared.reset { component, success in
//     print("重置 \(component): \(success ? "成功" : "失败")")
// } completion: { result in
//     switch result {
//     case .success:
//         print("✅ 应用已重置为全新状态")
//         AppResetManager.shared.restartApp()
//     case .partialFailure(let errors):
//         print("⚠️ 部分重置失败: \(errors)")
//     case .cancelled:
//         print("❌ 用户取消重置")
//     }
// }
//
// // 带确认弹窗的安全重置
// AppResetManager.shared.safeReset {
//     // 显示确认弹窗
//     await showConfirmAlert(title: "重置应用？", message: "所有本地数据将被清除")
// } completion: { result in
//     // 处理结果
// }
// */
