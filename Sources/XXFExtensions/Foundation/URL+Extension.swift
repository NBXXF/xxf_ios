//
//  URL+Extension.swift
//  xxf_ios
//
//  Created by xxf on /6/15.
//

import Foundation
import XXFSpeed

public extension URL {
    #if os(macOS)
        /// 获取主目录所在卷的 st_dev 设备号（仅计算一次）
        private static let homeVolumeDeviceID: Int32 = {
            var statbuf = stat()
            let homePath = FileManager.default.homeDirectoryForCurrentUser.path
            _ = homePath.withCString { lstat($0, &statbuf) }
            return statbuf.st_dev
        }()

        /// 获取主目录所在卷的 UUID（仅计算一次）
        private static let homeVolumeUUID: String? = {
            let homeURL = FileManager.default.homeDirectoryForCurrentUser
            return (try? homeURL.resourceValues(forKeys: [.volumeUUIDStringKey]))?.volumeUUIDString
        }()
    #endif

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
            // 比较 st_dev 是否属于主卷
            if statbuf.st_dev == Self.homeVolumeDeviceID,
               let uuid = Self.homeVolumeUUID
            {
                volumeID = "vol:\(uuid)"
            } else if let values = try? resourceValues(forKeys: [.volumeUUIDStringKey]),
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
    func isAliasFileOptimized() -> Bool {
        guard isFileURL else { return false }
        // 先用扩展名快速过滤，避免大量调用 resourceValues
        guard pathExtension.lowercased() == "alias" else { return false }
        return (try? resourceValues(forKeys: [.isAliasFileKey]))?.isAliasFile == true
    }

    /// 文件深度
    func calculateFileDepth() -> Int {
        let components = standardizedFileURL.pathComponents
        // 根目录 '/' 的 depth 设为 0，其它路径层数为 components 数减1
        return max(0, components.count - 1)
    }

    /// 是否在同一层级
    func isInSameDirectory(_ url: URL) -> Bool {
        // 获取父目录路径（去掉最后一个路径组件）
        let parent1 = url.deletingLastPathComponent().standardizedFileURL.path
        let parent2 = deletingLastPathComponent().standardizedFileURL.path
        return parent1 == parent2
    }
}
