//
//  DiskCache.swift
//  xxf_ios
//
//  磁盘缓存协议
//
//  设计说明:
//  定义磁盘缓存的统一接口，业务层使用此协议，无需关心底层实现。
//  支持多种磁盘缓存实现（如 HyperosloDiskCache），便于切换和测试。
//
//  协议要求:
//  - 线程安全：所有操作必须是线程安全的
//  - 过期支持：支持设置和检查过期时间
//  - 泛型支持：支持任意 Codable 类型
//
//  Created by xxf on 2025/3/5.
//

import Foundation

// MARK: - 磁盘缓存协议

/// 磁盘缓存协议
///
/// 定义磁盘缓存的统一接口。所有磁盘缓存实现都应遵循此协议。
///
/// ## 协议要求
/// - `Value` 必须实现 `Codable` 和 `Sendable`
/// - 所有方法必须是线程安全的
/// - 支持过期时间设置
///
/// ## 使用示例
/// ```swift
/// func saveUser<Cache: DiskCache>(cache: Cache, user: User) throws
///     where Cache.Value == User
/// {
///     try cache.set(user, forKey: "current_user", expiry: 3600)
/// }
/// ```
public protocol DiskCache: Sendable {
    /// 缓存值类型
    associatedtype Value: Codable & Sendable

    /// 缓存名称
    ///
    /// 用于标识缓存实例，通常用于日志和调试。
    var name: String { get }

    /// 存储对象
    ///
    /// 将对象序列化并存储到磁盘。
    ///
    /// - Parameters:
    ///   - value: 要缓存的对象
    ///   - key: 缓存 key，不能为空
    ///   - expiry: 过期时间（秒），nil 表示使用默认过期时间
    /// - Throws: 存储失败时抛出错误
    func set(_ value: Value, forKey key: String, expiry: TimeInterval?) throws

    /// 获取对象
    ///
    /// 从磁盘读取并反序列化对象。
    ///
    /// - Parameter key: 缓存 key，不能为空
    /// - Returns: 缓存的对象，不存在或已过期返回 nil
    /// - Throws: 读取失败时抛出错误（不包括 key 不存在的情况）
    func get(forKey key: String) throws -> Value?

    /// 删除对象
    ///
    /// 从磁盘删除指定 key 的缓存。
    ///
    /// - Parameter key: 缓存 key，不能为空
    /// - Throws: 删除失败时抛出错误（key 不存在不抛错）
    func remove(forKey key: String) throws

    /// 删除所有对象
    ///
    /// 清空该缓存实例的所有数据。
    ///
    /// - Throws: 清空失败时抛出错误
    func removeAll() throws

    /// 删除所有过期对象
    ///
    /// 清理已过期的缓存数据，释放磁盘空间。
    ///
    /// - Throws: 清理失败时抛出错误
    func removeExpired() throws

    /// 检查是否存在（且未过期）
    ///
    /// - Parameter key: 缓存 key，不能为空
    /// - Returns: 缓存是否存在且未过期
    /// - Throws: 检查失败时抛出错误
    func exists(forKey key: String) throws -> Bool

    /// 当前缓存大小（字节）
    ///
    /// 返回该缓存实例占用的磁盘空间。
    var totalSize: UInt64 { get }
}

// MARK: - 便捷方法

public extension DiskCache {
    /// 存储对象（使用默认过期时间）
    ///
    /// - Parameters:
    ///   - value: 要缓存的对象
    ///   - key: 缓存 key，不能为空
    /// - Throws: 存储失败时抛出错误
    func set(_ value: Value, forKey key: String) throws {
        try set(value, forKey: key, expiry: nil)
    }

    /// 安全获取对象（不抛出错误）
    ///
    /// - Parameter key: 缓存 key
    /// - Returns: 缓存的对象，任何错误都返回 nil
    func getOrNil(forKey key: String) -> Value? {
        try? get(forKey: key)
    }

    /// 安全删除对象（不抛出错误）
    ///
    /// - Parameter key: 缓存 key
    func removeIfExists(forKey key: String) {
        try? remove(forKey: key)
    }

    /// 获取或创建缓存
    ///
    /// 如果缓存存在则返回，否则调用 factory 创建并缓存。
    ///
    /// - Parameters:
    ///   - key: 缓存 key
    ///   - expiry: 过期时间（秒）
    ///   - factory: 创建值的闭包
    /// - Returns: 缓存的值或新创建的值
    /// - Throws: 存储或读取失败时抛出错误
    func getOrCreate(
        forKey key: String,
        expiry: TimeInterval? = nil,
        factory: () throws -> Value
    ) throws -> Value {
        if let cached = try get(forKey: key) {
            return cached
        }

        let value = try factory()
        try set(value, forKey: key, expiry: expiry)
        return value
    }
}

// MARK: - 批量操作扩展

public extension DiskCache {
    /// 批量检查存在性
    ///
    /// - Parameter keys: 缓存 key 列表
    /// - Returns: 存在的 key 集合
    func existingKeys(in keys: [String]) -> Set<String> {
        var result = Set<String>()
        for key in keys {
            if (try? exists(forKey: key)) == true {
                result.insert(key)
            }
        }
        return result
    }

    /// 批量删除
    ///
    /// - Parameter keys: 缓存 key 列表
    func removeAll(forKeys keys: [String]) {
        for key in keys {
            try? remove(forKey: key)
        }
    }
}

// MARK: - 统计信息扩展

public extension DiskCache {
    /// 格式化的缓存大小
    var formattedSize: String {
        let size = totalSize
        let kb = Double(size) / 1024
        let mb = kb / 1024

        if mb >= 1 {
            return String(format: "%.2f MB", mb)
        } else if kb >= 1 {
            return String(format: "%.2f KB", kb)
        } else {
            return "\(size) bytes"
        }
    }
}
