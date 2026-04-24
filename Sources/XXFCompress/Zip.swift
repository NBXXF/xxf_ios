//
//  Zip.swift
//  xxf_ios
//
//  Created by xxf on 4/24.
//

import Foundation

// MARK: - ZIP 快捷入口

/// ZIP 压缩/解压工具（基于 `ZIPFoundation` 的 `FileManager` 扩展）。
///
/// 设计目标：
/// 1. 保持 API 简单，覆盖最常见的压缩与解压场景。
/// 2. 与项目内其他模块风格一致，提供统一入口。
///
/// 注意事项：
/// - 传入路径必须是本地文件 URL（`fileURLWithPath`）。
/// - 目标路径若已有同名文件，通常会抛错；调用前建议先清理或更换路径。
/// - 该工具为同步调用；大文件操作建议放到后台队列执行。
public enum Zip {
    /// 将一个文件或目录压缩为 `.zip` 文件。
    ///
    /// - Parameters:
    ///   - sourceURL: 要压缩的源路径（文件或目录）。
    ///   - zipURL: 输出的 zip 文件路径（通常以 `.zip` 结尾）。
    ///   - shouldKeepParent:
    ///     - `true`：保留源目录本身作为 zip 根节点（默认）。
    ///     - `false`：仅压缩目录内容，不包含父目录名。
    /// - Throws:
    ///   - 当源路径不存在、无读写权限、目标文件冲突、磁盘空间不足等情况会抛错。
    ///
    /// 示例：
    /// ```swift
    /// let sourceURL = URL(fileURLWithPath: "/tmp/demo_folder")
    /// let zipURL = URL(fileURLWithPath: "/tmp/demo.zip")
    ///
    /// // 如果目标已存在，先删除，避免冲突
    /// if FileManager.default.fileExists(atPath: zipURL.path) {
    ///     try FileManager.default.removeItem(at: zipURL)
    /// }
    ///
    /// try Zip.zipItem(at: sourceURL, to: zipURL, shouldKeepParent: true)
    /// ```
    public static func zipItem(
        at sourceURL: URL,
        to zipURL: URL,
        shouldKeepParent: Bool = true
    ) throws {
        try FileManager.default.zipItem(
            at: sourceURL,
            to: zipURL,
            shouldKeepParent: shouldKeepParent
        )
    }

    /// 将 `.zip` 文件解压到目标目录。
    ///
    /// - Parameters:
    ///   - zipURL: zip 文件路径。
    ///   - destinationURL: 解压目标目录路径。
    /// - Throws:
    ///   - 当 zip 文件不存在、格式损坏、无写权限、磁盘空间不足等情况会抛错。
    ///
    /// 示例：
    /// ```swift
    /// let zipURL = URL(fileURLWithPath: "/tmp/demo.zip")
    /// let destURL = URL(fileURLWithPath: "/tmp/unzip")
    ///
    /// if !FileManager.default.fileExists(atPath: destURL.path) {
    ///     try FileManager.default.createDirectory(at: destURL, withIntermediateDirectories: true)
    /// }
    ///
    /// try Zip.unzipItem(at: zipURL, to: destURL)
    /// ```
    public static func unzipItem(
        at zipURL: URL,
        to destinationURL: URL
    ) throws {
        try FileManager.default.unzipItem(at: zipURL, to: destinationURL)
    }
}
