//
//  DiskCacheConfig.swift
//  xxf_ios
//
//  磁盘缓存配置
//
//  用于配置 DiskCache 实现的各项参数，包括：
//  - 缓存名称：用于区分不同的缓存实例
//  - 过期时间：控制缓存的默认生命周期
//  - 容量限制：防止磁盘占用过大
//  - 存储目录：自定义缓存文件位置
//
//  Created by xxf on 2023/3/5.
//

import Foundation

// MARK: - 磁盘缓存配置

/// 磁盘缓存配置
///
/// 用于配置 `DiskCache` 实现类的行为参数。
/// 所有参数都会进行校验，确保配置值合理。
///
/// ## 使用示例
/// ```swift
/// // 使用默认配置
/// let defaultConfig = DiskCacheConfig.default
///
/// // 自定义配置
/// let customConfig = DiskCacheConfig(
///     name: "ImageCache",
///     defaultExpiry: 7 * 24 * 60 * 60,  // 7天
///     maxSize: 512 * 1024 * 1024        // 512MB
/// )
/// ```
public struct DiskCacheConfig: Sendable {
    // MARK: - Properties

    /// 缓存名称
    ///
    /// 用于区分不同的缓存实例，会影响缓存文件的存储路径。
    /// - Note: 名称不能为空，会自动过滤非法字符
    public let name: String

    /// 默认过期时间（秒）
    ///
    /// 当存储对象未指定过期时间时使用此值。
    /// - Note: 最小值为 60 秒（1分钟）
    public let defaultExpiry: TimeInterval

    /// 最大缓存大小（字节）
    ///
    /// 限制缓存占用的磁盘空间，超出时会自动清理旧数据。
    /// - Note: 0 表示不限制，最小限制为 1MB
    public let maxSize: UInt64

    /// 缓存目录
    ///
    /// 指定缓存文件的存储位置。
    /// - Note: nil 表示使用系统默认的 Caches 目录
    public let directory: URL?

    // MARK: - Presets

    /// 默认配置
    ///
    /// - 名称: "Default"
    /// - 过期时间: 3天
    /// - 最大容量: 256MB
    public static let `default` = DiskCacheConfig(
        name: "Default",
        defaultExpiry: 3 * 24 * 60 * 60,
        maxSize: 256 * 1024 * 1024
    )

    /// 短期缓存配置
    ///
    /// 适用于临时数据，如搜索结果、列表数据等
    /// - 过期时间: 1小时
    /// - 最大容量: 64MB
    public static let shortTerm = DiskCacheConfig(
        name: "ShortTerm",
        defaultExpiry: 60 * 60,
        maxSize: 64 * 1024 * 1024
    )

    /// 长期缓存配置
    ///
    /// 适用于不常变化的数据，如用户资料、配置信息等
    /// - 过期时间: 30天
    /// - 最大容量: 512MB
    public static let longTerm = DiskCacheConfig(
        name: "LongTerm",
        defaultExpiry: 30 * 24 * 60 * 60,
        maxSize: 512 * 1024 * 1024
    )

    // MARK: - Initialization

    /// 创建磁盘缓存配置
    /// - Parameters:
    ///   - name: 缓存名称，用于区分不同缓存
    ///   - defaultExpiry: 默认过期时间（秒），最小 60 秒
    ///   - maxSize: 最大缓存大小（字节），0 表示不限制
    ///   - directory: 缓存目录，nil 使用默认 Caches 目录
    public init(
        name: String,
        defaultExpiry: TimeInterval = 3 * 24 * 60 * 60,
        maxSize: UInt64 = 256 * 1024 * 1024,
        directory: URL? = nil
    ) {
        // 名称校验：不能为空，过滤非法字符
        let sanitizedName = Self.sanitizeName(name)
        self.name = sanitizedName.isEmpty ? "Default" : sanitizedName

        // 过期时间校验：最小 60 秒
        self.defaultExpiry = max(60, defaultExpiry)

        // 容量校验：0 表示不限制，否则最小 1MB
        if maxSize > 0 {
            self.maxSize = max(1024 * 1024, maxSize)
        } else {
            self.maxSize = 0
        }

        // 目录校验：确保是目录而非文件
        if let dir = directory {
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: dir.path, isDirectory: &isDirectory) {
                self.directory = isDirectory.boolValue ? dir : nil
            } else {
                // 目录不存在，尝试创建
                do {
                    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                    self.directory = dir
                } catch {
                    #if DEBUG
                        print("[DiskCacheConfig] Failed to create directory: \(error)")
                    #endif
                    self.directory = nil
                }
            }
        } else {
            self.directory = nil
        }
    }

    // MARK: - Private Helpers

    /// 清理缓存名称中的非法字符
    /// - Parameter name: 原始名称
    /// - Returns: 清理后的名称
    private static func sanitizeName(_ name: String) -> String {
        // 移除文件系统不允许的字符
        let invalidCharacters = CharacterSet(charactersIn: "/\\:*?\"<>|")
        let components = name.components(separatedBy: invalidCharacters)
        return components.joined()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Computed Properties

public extension DiskCacheConfig {
    /// 是否有容量限制
    var hasMaxSizeLimit: Bool {
        maxSize > 0
    }

    /// 格式化的最大容量字符串
    var formattedMaxSize: String {
        guard maxSize > 0 else { return "Unlimited" }

        let kb = Double(maxSize) / 1024
        let mb = kb / 1024
        let gb = mb / 1024

        if gb >= 1 {
            return String(format: "%.1f GB", gb)
        } else if mb >= 1 {
            return String(format: "%.1f MB", mb)
        } else {
            return String(format: "%.1f KB", kb)
        }
    }

    /// 格式化的过期时间字符串
    var formattedExpiry: String {
        let minutes = Int(defaultExpiry / 60)
        let hours = minutes / 60
        let days = hours / 24

        if days > 0 {
            return "\(days) day\(days > 1 ? "s" : "")"
        } else if hours > 0 {
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        } else {
            return "\(minutes) minute\(minutes > 1 ? "s" : "")"
        }
    }
}

// MARK: - Builder Pattern

public extension DiskCacheConfig {
    /// 创建配置的副本，修改名称
    /// - Parameter name: 新名称
    /// - Returns: 新配置
    func withName(_ name: String) -> DiskCacheConfig {
        DiskCacheConfig(
            name: name,
            defaultExpiry: defaultExpiry,
            maxSize: maxSize,
            directory: directory
        )
    }

    /// 创建配置的副本，修改过期时间
    /// - Parameter expiry: 新过期时间（秒）
    /// - Returns: 新配置
    func withExpiry(_ expiry: TimeInterval) -> DiskCacheConfig {
        DiskCacheConfig(
            name: name,
            defaultExpiry: expiry,
            maxSize: maxSize,
            directory: directory
        )
    }

    /// 创建配置的副本，修改最大容量
    /// - Parameter size: 新最大容量（字节）
    /// - Returns: 新配置
    func withMaxSize(_ size: UInt64) -> DiskCacheConfig {
        DiskCacheConfig(
            name: name,
            defaultExpiry: defaultExpiry,
            maxSize: size,
            directory: directory
        )
    }

    /// 创建配置的副本，修改存储目录
    /// - Parameter url: 新存储目录
    /// - Returns: 新配置
    func withDirectory(_ url: URL?) -> DiskCacheConfig {
        DiskCacheConfig(
            name: name,
            defaultExpiry: defaultExpiry,
            maxSize: maxSize,
            directory: url
        )
    }
}

// MARK: - Debug Support

#if DEBUG
    extension DiskCacheConfig: CustomDebugStringConvertible {
        public var debugDescription: String {
            """
            DiskCacheConfig(
                name: "\(name)",
                expiry: \(formattedExpiry),
                maxSize: \(formattedMaxSize),
                directory: \(directory?.path ?? "default")
            )
            """
        }
    }
#endif
