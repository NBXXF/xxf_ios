//
//  URL+Extension.swift
//  xxf_ios
//
//  Created by xxf on /6/15.
//

import Foundation
import XXFSpeed

public extension URL {
    /// 返回当前平台下尽可能唯一、稳定的文件 ID，适用于 macOS / iOS。
    ///
    /// 结构类似于：
    /// - macOS: "vol:06A2F1CE-XXXX-XXXX-XXXX-XXXXXXXXXXXX-ino:123456"
    /// - iOS: "dev:16777220-ino:123456"
    ///
    /// - Parameter path: 文件路径
    /// - Returns: 唯一标识符字符串，或path.hash
    func getFileId() -> UInt64 {
        // 只对文件 URL 生效
        guard isFileURL else {
            return path.toXXH3()
        }

        var statbuf = stat()
        let ok = withUnsafeFileSystemRepresentation { cPath -> Bool in
            guard let cPath = cPath else { return false }
            return lstat(cPath, &statbuf) == 0
        }

        guard ok else {
            // lstat 失败或路径非法，退化到对路径字符串做哈希
            return path.toXXH3()
        }

        let inodeID = "ino:\(statbuf.st_ino)"
        let deviceID = "dev:\(statbuf.st_dev)"
        var volumeID = deviceID

        // macOS 上尝试 volumeUUID（iOS 上这段通常会失败）
        #if os(macOS)
            if let values = try? resourceValues(forKeys: [.volumeUUIDStringKey]),
               let uuid = values.volumeUUIDString
            {
                volumeID = "vol:\(uuid)"
            } else {
                volumeID = deviceID
            }
        #endif
        return "\(volumeID)-\(inodeID)".toXXH3()
    }

    // 是否是文件夹（仅本地文件 URL）
    func isDirectory() -> Bool {
        guard isFileURL else { return false }
        return path.withCString { cstr in
            var statbuf = stat()
            if lstat(cstr, &statbuf) == 0 {
                return (statbuf.st_mode & S_IFMT) == S_IFDIR
            }
            return false
        }
    }

    /// 是否是符号链接（仅本地文件 URL）
    func isSymbolicLink() -> Bool {
        guard isFileURL else { return false }
        return path.withCString { cstr in
            var statbuf = stat()
            return lstat(cstr, &statbuf) == 0 && (statbuf.st_mode & S_IFMT) == S_IFLNK
        }
    }

    /// 是否是 Finder 替身（Alias 文件）（仅本地文件 URL）
    func isAliasFile() -> Bool {
        guard isFileURL else { return false }
        return (try? resourceValues(forKeys: [.isAliasFileKey]))?.isAliasFile == true
    }

    /// 文件深度
    func calculateFileDepth() -> Int {
        let components = standardizedFileURL.pathComponents
        // 根目录 '/' 的 depth 设为 0，其它路径层数为 components 数减1
        return max(0, components.count - 1)
    }
}
