//
//  FileManager+Extension.swift
//  xxf_ios
//  文件存储位置
//  Created by xxf on /6/2.
//

import Foundation

public extension FileManager {
    /// 适合持久化存储的目录（数据库、配置、日志等）
    /// 兼容 macOS / iOS / tvOS / watchOS / 其他平台
    func applicationSupportDirectory() -> URL {
        #if os(macOS)
            let urls = Self.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let baseDir = urls[0].appendingPathComponent(Bundle.main.bundleIdentifier ?? "App", isDirectory: true)
        #elseif os(iOS) || os(tvOS) || os(watchOS)
            let urls = Self.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let baseDir = urls[0]
        #else
            let baseDir = Self.default.temporaryDirectory
        #endif

        try? Self.default.createDirectory(at: baseDir, withIntermediateDirectories: true)
        return baseDir
    }

    /// 适合临时缓存使用的目录（图片缓存、下载临时文件等）
    /// 兼容 macOS / iOS / tvOS / watchOS / 其他平台
    func cachesDirectory() -> URL {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let urls = Self.default.urls(for: .cachesDirectory, in: .userDomainMask)
            let baseDir = urls[0]
        #else
            let baseDir = Self.default.temporaryDirectory
        #endif

        return baseDir
    }

    /// 适合导出用户可见文档、持久内容（如 PDF、Excel）
    /// ⚠️ 注意：iOS 中该目录仅限沙盒，用户不可直接查看
    func documentDirectory() -> URL {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let urls = Self.default.urls(for: .documentDirectory, in: .userDomainMask)
            let baseDir = urls[0]
        #else
            let baseDir = Self.default.temporaryDirectory
        #endif

        return baseDir
    }

    /// Library 目录（包含 Caches、Preferences、Application Support）
    func libraryDirectory() -> URL {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let urls = Self.default.urls(for: .libraryDirectory, in: .userDomainMask)
            let baseDir = urls[0]
        #else
            let baseDir = Self.default.temporaryDirectory
        #endif

        return baseDir
    }
}
