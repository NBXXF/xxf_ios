//
//  FileManager+Directory.swift
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
            let urls = self.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let baseDir = urls[0].appendingPathComponent(Bundle.main.bundleIdentifier ?? "App", isDirectory: true)
        #elseif os(iOS) || os(tvOS) || os(watchOS)
            let urls = self.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let baseDir = urls[0]
        #else
            let baseDir = temporaryDirectory
        #endif

        try? createDirectory(at: baseDir, withIntermediateDirectories: true)
        return baseDir
    }

    /// 适合临时缓存使用的目录（图片缓存、下载临时文件等）
    /// 兼容 macOS / iOS / tvOS / watchOS / 其他平台
    func cachesDirectory() -> URL {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let urls = self.urls(for: .cachesDirectory, in: .userDomainMask)
            let baseDir = urls[0]
        #else
            let baseDir = temporaryDirectory
        #endif

        return baseDir
    }

    /// 适合导出用户可见文档、持久内容（如 PDF、Excel）
    /// ⚠️ 注意：iOS 中该目录仅限沙盒，用户不可直接查看
    func documentDirectory() -> URL {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let urls = self.urls(for: .documentDirectory, in: .userDomainMask)
            let baseDir = urls[0]
        #else
            let baseDir = temporaryDirectory
        #endif

        return baseDir
    }

    /// Library 目录（包含 Caches、Preferences、Application Support）
    func libraryDirectory() -> URL {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
            let urls = self.urls(for: .libraryDirectory, in: .userDomainMask)
            let baseDir = urls[0]
        #else
            let baseDir = temporaryDirectory
        #endif

        return baseDir
    }

    /// 回收站目录（仅 macOS 有效）
    /// - 优先使用系统 API (`.trashDirectory`, macOS 10.8+)
    /// - 如果获取失败，则 fallback 到 `~/.Trash`
    @available(macOS 10.8, *)
     func trashDirectory() -> URL {
         // macOS 13 / iOS 16 及以上：使用系统新 API
         if #available(iOS 16.0, macOS 13.0, *) {
             return URL.trashDirectory
         }

         // 旧版本 macOS 或 iOS：尝试通过 FileManager 获取
         if let url = try? url(for: .trashDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
             return url
         }

         // macOS 专属的用户主目录回退逻辑
         #if os(macOS)
         return homeDirectoryForCurrentUser.appendingPathComponent(".Trash", isDirectory: true)
         #else
         // iOS 没有全局 Trash 概念，用临时目录代替
         let fallback = temporaryDirectory.appendingPathComponent("Trash", isDirectory: true)
         try? createDirectory(at: fallback, withIntermediateDirectories: true)
         return fallback
         #endif
     }
}
