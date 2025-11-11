//
//  FileManager+Metadata.swift
//  xxf_ios
//  通过文件管理器获取文件元信息(有限！！！)
//  Created by xxf 6/2.
//

import Foundation

public extension FileManager {
    // MARK: — 文件级属性 (1–17)

    /// 1. 获取文件大小（字节）
    func fileSize(atPath path: String) -> UInt64? {
        guard let v = try? attributesOfItem(atPath: path)[.size] as? NSNumber else { return nil }
        return v.uint64Value
    }

    /// 2. 获取文件创建时间
    func creationDate(atPath path: String) -> Date? {
        return try? attributesOfItem(atPath: path)[.creationDate] as? Date
    }

    /// 3. 获取文件最后修改时间
    func modificationDate(atPath path: String) -> Date? {
        return try? attributesOfItem(atPath: path)[.modificationDate] as? Date
    }

    /// 4. 获取文件类型（如：文件／目录／符号链接等）
    func fileType(atPath path: String) -> FileAttributeType? {
        return try? attributesOfItem(atPath: path)[.type] as? FileAttributeType
    }

    /// 5. 获取文件所有者用户名
    func ownerAccountName(atPath path: String) -> String? {
        return try? attributesOfItem(atPath: path)[.ownerAccountName] as? String
    }

    /// 6. 获取文件所有者用户 ID（UID），返回 UInt32?
    func ownerAccountID(atPath path: String) -> UInt32? {
        guard let v = try? attributesOfItem(atPath: path)[.ownerAccountID] as? NSNumber else { return nil }
        return v.uint32Value
    }

    /// 7. 获取文件所属用户组名称
    func groupOwnerAccountName(atPath path: String) -> String? {
        return try? attributesOfItem(atPath: path)[.groupOwnerAccountName] as? String
    }

    /// 8. 获取文件所属用户组 ID（GID），返回 UInt32?
    func groupOwnerAccountID(atPath path: String) -> UInt32? {
        guard let v = try? attributesOfItem(atPath: path)[.groupOwnerAccountID] as? NSNumber else { return nil }
        return v.uint32Value
    }

    /// 9. 获取文件的 POSIX 权限（如 0o755）
    func posixPermissions(atPath path: String) -> NSNumber? {
        return try? attributesOfItem(atPath: path)[.posixPermissions] as? NSNumber
    }

    /// 10. 获取文件的硬链接数量（引用次数）
    func referenceCount(atPath path: String) -> Int? {
        guard let v = try? attributesOfItem(atPath: path)[.referenceCount] as? NSNumber else { return nil }
        return v.intValue
    }

    /// 11. 判断文件是否处于“繁忙”状态（busy flag）
    func isBusy(atPath path: String) -> Bool? {
        guard let v = try? attributesOfItem(atPath: path)[.busy] as? NSNumber else { return nil }
        return v.boolValue
    }

    /// 12. 判断文件是否设置为不可变（immutable flag）
    func isImmutable(atPath path: String) -> Bool? {
        guard let v = try? attributesOfItem(atPath: path)[.immutable] as? NSNumber else { return nil }
        return v.boolValue
    }

    /// 13. 判断文件是否为只追加模式（append-only flag）
    func isAppendOnly(atPath path: String) -> Bool? {
        guard let v = try? attributesOfItem(atPath: path)[.appendOnly] as? NSNumber else { return nil }
        return v.boolValue
    }

    /// 14. 获取 HFS 创建者码（4 字节代码）
    func hfsCreatorCode(atPath path: String) -> FourCharCode? {
        guard let v = try? attributesOfItem(atPath: path)[.hfsCreatorCode] as? NSNumber else { return nil }
        return FourCharCode(v.uint32Value)
    }

    /// 15. 获取 HFS 文件类型码（4 字节代码）
    func hfsTypeCode(atPath path: String) -> FourCharCode? {
        guard let v = try? attributesOfItem(atPath: path)[.hfsTypeCode] as? NSNumber else { return nil }
        return FourCharCode(v.uint32Value)
    }

    /// 16. 判断文件是否隐藏扩展名（仅限部分文件类型）
    func isExtensionHidden(atPath path: String) -> Bool? {
        guard let v = try? attributesOfItem(atPath: path)[.extensionHidden] as? NSNumber else { return nil }
        return v.boolValue
    }

    /// 17. 获取文件的保护级别（如 NSFileProtectionComplete）
    func protectionKey(atPath path: String) -> String? {
        return try? attributesOfItem(atPath: path)[.protectionKey] as? String
    }

    // MARK: — 文件系统级属性 (18–24)

    /// 18. 获取文件所在文件系统的设备号（systemNumber）
    func systemNumber(ofVolumeAtPath path: String) -> NSNumber? {
        return try? attributesOfFileSystem(forPath: path)[.systemNumber] as? NSNumber
    }

    /// 19. 获取文件在文件系统中的 inode 编号（systemFileNumber）
    func systemFileNumber(ofVolumeAtPath path: String) -> NSNumber? {
        return try? attributesOfFileSystem(forPath: path)[.systemFileNumber] as? NSNumber
    }

    /// 20. 获取文件系统总容量（字节）（systemSize）
    func systemSize(ofVolumeAtPath path: String) -> UInt64? {
        guard let v = try? attributesOfFileSystem(forPath: path)[.systemSize] as? NSNumber else { return nil }
        return v.uint64Value
    }

    /// 21. 获取文件系统剩余可用空间（字节）（systemFreeSize）
    func systemFreeSize(ofVolumeAtPath path: String) -> UInt64? {
        guard let v = try? attributesOfFileSystem(forPath: path)[.systemFreeSize] as? NSNumber else { return nil }
        return v.uint64Value
    }

    /// 22. 获取文件系统节点总数（inode 总数）（systemNodes）
    func systemNodes(ofVolumeAtPath path: String) -> NSNumber? {
        return try? attributesOfFileSystem(forPath: path)[.systemNodes] as? NSNumber
    }

    /// 23. 获取文件系统剩余节点数（可用 inode 数）（systemFreeNodes）
    func systemFreeNodes(ofVolumeAtPath path: String) -> NSNumber? {
        return try? attributesOfFileSystem(forPath: path)[.systemFreeNodes] as? NSNumber
    }

    /// 24. 获取文件系统设备标识符（deviceIdentifier）
    func deviceIdentifier(ofVolumeAtPath path: String) -> NSNumber? {
        return try? attributesOfFileSystem(forPath: path)[.deviceIdentifier] as? NSNumber
    }
}
