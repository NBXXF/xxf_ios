//
//  FileTimes.swift
//  xxf_ios
//  文件时间
//  Created by xxf on 7/8.
//

import Foundation

/**
 文件属性变化对时间戳的影响
 操作 / 属性变更                               creationTime (birthtime)                                modificationTime (mtime)                          accessTime (atime)                changeTime (ctime)
 内容写入/覆盖                                  不变                                                               ✅ 更新                                                   可能更新（读写混合时）         ✅ 更新
 读取文件内容                                   不变                                                              不变                                                           ✅ 更新（可能延迟/禁用）      不变
 重命名                                             不变                                                               不变                                                          不变                                           ✅ 更新
 移动（同卷）                                  不变                                                                不变                                                          不变                                          ✅ 更新
 移动（跨卷）                                ❓ 可能重置                                                   ❓ 可能保留                                              不确定                                      ❓ 可能重置
 修改权限 (chmod)                           不变                                                                不变                                                          不变                                          ✅ 更新
 修改所有者 (chown/chgrp)              不变                                                               不变                                                           不变                                          ✅ 更新
 修改扩展属性 (xattr)                         不变                                                               不变                                                           不变                                          ✅ 更新
 修改 ACL (访问控制列表)                 不变                                                                不变                                                          不变                                          ✅ 更新
 修改 Finder 标签 (Color Tag)    不变                                                                       不变                                                            不变                                         ✅ 更新
 修改 Spotlight 注释 (kMDItemFinderComment)    不变                                         不变                                                             不变                                         ✅ 更新
 修改 Finder Info（图标位置、显示选项）    不变                                                   不变                                                            不变                                          ✅ 更新
 添加/删除资源分叉 (resource fork)    不变                                                             ✅ 更新（内容变化）                                  不变                                         ✅ 更新
 修改 Extended Metadata (com.apple. xattr)*    不变                                            不变                                                              不变                                        ✅ 更新
 */
///  一次性通过 `stat()` 获取并返回文件的所有时间戳
///
/// - Returns: 一个 `FileTimes` 实例，包含：
///
///   - `creationTime` (birthtime)
///     * 文件创建时间
///     * 对应 Spotlight: **kMDItemFSCreationDate**
///     * 只在 **新建文件** 或 **跨卷复制** 时变化
///     * 不会因为修改内容、修改权限、改标签、重命名而变化
///     * ⭐ 非 macOS 平台（如 Linux ext4）通常没有真正的 birthtime，可能退化为 ctime
///
///   - `modificationTime` (mtime)
///     * 文件内容最后修改时间
///     * 对应 Spotlight: **kMDItemFSContentChangeDate**
///     * **写入/覆盖内容**、**修改资源分叉 (resource fork)** 会更新
///     * **不会因为修改权限/标签/注释/重命名/移动** 而变化
///
///   - `accessTime` (atime)
///     * 文件最后访问时间
///     * 对应 Spotlight: **kMDItemLastUsedDate**
///     * **读取文件内容**（如 read/open）会更新
///     * ⭐ macOS/APFS 默认启用 `noatime` 优化，不会实时更新，实际值可能恒久不变
///     * **不会因为修改内容或属性** 而变化
///
///   - `changeTime` (ctime)
///     * 文件状态（inode 元数据）最后修改时间
///     * Spotlight **没有对应字段**
///     * ⭐ 注意：ctime ≠ creationTime，不能作为文件创建时间使用
///     * **几乎所有元数据变化都会更新**，包括：
///       - 内容修改（同时改 mtime）
///       - 权限修改 (chmod)
///       - 所有者/用户组修改 (chown/chgrp)
///       - 扩展属性 (xattr) 变化（例如 Finder 标签 `com.apple.metadata:_kMDItemUserTags`）
///       - Spotlight Finder 注释 (kMDItemFinderComment)
///       - ACL（访问控制列表）变化
///       - 重命名、移动（同一卷内）
///       - 移动到回收站（实质是重命名/移动目录项）
///     * **不更新的例子**：仅仅读取文件
///
/// **常见操作 vs 时间戳变化总结：**
/// - 新建：所有时间 = 当前时间
/// - 内容修改：mtime、ctime 更新
/// - 读取内容：atime 更新（可能延迟/禁用）
/// - 重命名：ctime 更新
/// - 移动（同一卷）：ctime 更新
/// - 移动（跨卷）：可能重置 birthtime，mtime 可能保留或重置
/// - 改权限/所有者：ctime 更新
/// - 修改 Finder 标签/注释 (xattr)：ctime 更新
/// - 移动到回收站：ctime 更新（本质是重命名）
/// - 复制：birthtime 新建，mtime 是否保留取决于复制工具（如 `cp -p`）；⭐ Spotlight/Finder 会把 kMDItemFSCreationDate 设置为新建时间
///
/// 四个文件时间戳模型
public struct FileTimes {
    /// 文件创建时间（birthtime）
    public let creationTime: Date?
    /// 文件内容最后修改时间（mtime）
    public let modificationTime: Date?
    /// 文件最后访问时间（atime）
    public let accessTime: Date?
    /// 文件状态变更时间（ctime）
    public let changeTime: Date?
}
