//
//  URL+XAttr.swift
//  xxf_ios
//  xattr相关操作 URL 扩展
//  Created by xxf on 6/2.
//

import Foundation

public extension URL {
    // MARK: - 命名空间处理

    /// 已废弃方法，保留兼容性，建议改用 `xattrNamespacedKey(_:)`
    ///
    /// - Parameter key: 原始的扩展属性 key
    /// - Returns: 加上 bundleId 命名空间后的 key
    @available(*, deprecated, message: "建议使用 xattrNamespacedKey 方法")
    func attrNamespacedKey(_ key: String) -> String {
        return xattrNamespacedKey(key)
    }

    /// 生成带 App Bundle Identifier 命名空间的 xattr key
    ///
    /// - Parameter key: 原始扩展属性 key（如 `"meta"`）
    /// - Returns: 命名空间前缀的完整 key（如 `"com.example.myapp.meta"`）
    /// - Note: 若当前环境无有效 `bundleIdentifier`，将使用 `"com.unknown.app"` 作为默认命名空间
    func xattrNamespacedKey(_ key: String) -> String {
        let bundleId = Bundle.main.bundleIdentifier ?? "com.unknown.app"
        if key.hasPrefix(bundleId + ".") {
            return key
        }
        return "\(bundleId).\(key)"
    }

    // MARK: - 写入 xattr

    /// 将任意 `Encodable` 类型写入指定扩展属性（xattr）key
    ///
    /// - Parameters:
    ///   - key: 扩展属性 key，建议使用 `xattrNamespacedKey` 包装
    ///   - value: 要写入的数据，支持任何 `Encodable` 类型
    ///   - flags: `setxattr` 标志，默认为 0，可传如 `XATTR_REPLACE` 等
    ///   - encoder: JSON 编码器，默认为 `JSONEncoder()`
    /// - Throws: 写入失败时抛出 `XattrError` 错误
    func setXattr<T: Encodable>(
        key: String,
        value: T,
        flags: Int32 = 0,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        try XattrWriter().write(
            path: standardizedFileURL.path,
            key: key,
            value: value,
            flags: flags,
            encoder: encoder
        )
    }

    // MARK: - 读取 xattr（带类型参数）

    /// 读取指定扩展属性并解码为指定类型
    ///
    /// - Parameters:
    ///   - key: 扩展属性 key
    ///   - type: 解码目标类型（如 `Int.self`）
    ///   - decoder: JSON 解码器，默认为 `JSONDecoder()`
    /// - Returns: 解码后的数据
    /// - Throws: 若扩展属性不存在、格式错误或解码失败，则抛出 `XattrError`
    func getXattr<T: Decodable>(
        key: String,
        as type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        try XattrReader().read(
            path: standardizedFileURL.path,
            key: key,
            as: type,
            decoder: decoder
        )
    }

    /// 尝试读取指定扩展属性（可空）
    ///
    /// - Parameters:
    ///   - key: 扩展属性 key
    ///   - type: 解码目标类型
    ///   - decoder: JSON 解码器
    /// - Returns: 解码成功则返回对应值，否则返回 `nil`
    func getXattrOrNil<T: Decodable>(
        key: String,
        as type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) -> T? {
        try? getXattr(key: key, as: type, decoder: decoder)
    }

    /// 尝试读取指定扩展属性，若失败则返回默认值
    ///
    /// - Parameters:
    ///   - key: 扩展属性 key
    ///   - type: 解码目标类型
    ///   - decoder: JSON 解码器
    ///   - fallback: 默认值表达式（只有失败时才求值）
    /// - Returns: 解码成功返回对应值，否则返回 fallback 的结果
    func getXattr<T: Decodable>(
        key: String,
        as type: T.Type,
        decoder: JSONDecoder = JSONDecoder(),
        or fallback: @autoclosure () -> T
    ) -> T {
        getXattrOrNil(key: key, as: type, decoder: decoder) ?? fallback()
    }

    // MARK: - 简洁版（省略类型参数）

    /// 读取指定扩展属性，自动推断类型（需赋值语句指定类型）
    ///
    /// - Parameters:
    ///   - key: 扩展属性 key
    ///   - decoder: JSON 解码器
    /// - Returns: 解码后的数据
    /// - Throws: 若读取或解码失败则抛出异常
    func getXattr<T: Decodable>(
        key: String,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        try getXattr(key: key, as: T.self, decoder: decoder)
    }

    /// 尝试读取扩展属性，可推断类型（失败返回 nil）
    ///
    /// - Parameters:
    ///   - key: 扩展属性 key
    ///   - decoder: JSON 解码器
    /// - Returns: 解码成功则返回对应值，否则返回 `nil`
    func getXattrOrNil<T: Decodable>(
        key: String,
        decoder: JSONDecoder = JSONDecoder()
    ) -> T? {
        try? getXattr(key: key, as: T.self, decoder: decoder)
    }

    /// 尝试读取扩展属性，失败时返回默认值（可推断类型）
    ///
    /// - Parameters:
    ///   - key: 扩展属性 key
    ///   - decoder: JSON 解码器
    ///   - fallback: 默认值（自动闭包，仅在失败时执行）
    /// - Returns: 解码成功则返回对应值，否则返回默认值
    func getXattr<T: Decodable>(
        key: String,
        decoder: JSONDecoder = JSONDecoder(),
        or fallback: @autoclosure () -> T
    ) -> T {
        getXattrOrNil(key: key, decoder: decoder) ?? fallback()
    }
}
