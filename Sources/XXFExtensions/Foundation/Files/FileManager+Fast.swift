//
//  FileManager+Fast.swift
//  xxf_ios
//  文件存储位置
//  Created by xxf on 2025/6/2.
//

import Foundation

public extension FileManager {
    /// 更快的判断文件是否存在（基于 stat，性能优于 fileExists(atPath:)）
    /// - Parameter path: 文件路径
    /// - Returns: 文件是否存在
    func fileExistsFast(atPath path: String) -> Bool {
        guard !path.isEmpty else { return false }
        var info = stat()
        return path.withCString { stat($0, &info) == 0 }
    }

    /// 是否指向一个已存在的目录（使用 FileManager 的 fileExists）
    /// - Parameter url: 文件 URL
    /// - Returns: 是否为目录
    func isDirectory(at url: URL) -> Bool {
        var isDir: ObjCBool = false
        // 只做 exist + type 检查，不抛异常
        let exists = fileExists(atPath: url.path, isDirectory: &isDir)
        return exists && isDir.boolValue
    }

    /// 基于 stat() 的高性能判断：存在且为目录
    /// - Parameter path: 文件路径
    /// - Returns: 是否为存在的目录
    func isDirectoryFast(atPath path: String) -> Bool {
        guard !path.isEmpty else { return false }
        var info = stat()
        guard stat(path, &info) == 0 else {
            return false
        }
        // st_mode 的类型掩码为目录
        return (info.st_mode & S_IFMT) == S_IFDIR
    }

    /// URL 版本的 isDirectoryFast
    /// - Parameter url: 文件路径 URL
    /// - Returns: 是否为目录
    func isDirectoryFast(at url: URL) -> Bool {
        isDirectoryFast(atPath: url.path)
    }
}
