//
//  URL+XAttr.swift
//  xxf_ios
//  xattr相关操作 URL 扩展
//  Created by xxf 6/2.
//

import Foundation

public extension URL {
    /// 旧方法，已废弃，仅保留兼容调用
    /// - Parameter key: 原始的扩展属性 key
    /// - Returns: 带 bundleId 命名空间的完整扩展属性 key
    @available(*, deprecated, message: "建议使用 xattrNamespacedKey 方法")
    func attrNamespacedKey(_ key: String) -> String {
        return xattrNamespacedKey(key)
    }

    /// 生成带有 App Bundle Identifier 命名空间的 xattr key
    ///
    /// 该方法用于防止扩展属性 key 冲突，自动在 key 前添加当前应用的 bundle identifier 作为命名空间。
    /// 在单元测试、Playground 等环境下，bundle identifier 可能为空，此时默认使用 `"com.unknown.app"`。
    ///
    /// - Parameter key: 原始扩展属性 key（如 `"meta"`）
    /// - Returns: 带命名空间的完整扩展属性 key（如 `"com.example.myapp.meta"`）
    func xattrNamespacedKey(_ key: String) -> String {
        let bundleId = Bundle.main.bundleIdentifier ?? "com.unknown.app"
        if key.hasPrefix(bundleId + ".") {
            return key
        }
        return "\(bundleId).\(key)"
    }

    /// 设置文件的扩展属性（xattr）
    ///
    /// 将指定值编码后写入到指定的扩展属性 key 中。支持任意 `Encodable` 类型，默认使用 JSONEncoder 进行编码。
    ///
    /// - Parameters:
    ///   - key: 扩展属性的 key，建议使用 `xattrNamespacedKey` 生成带命名空间的 key，避免冲突
    ///   - value: 需要写入的值，支持任意 `Encodable` 类型
    ///   - flags: 写入标志，默认为 0，参考 `setxattr` 函数相关标志位（如 `XATTR_REPLACE` 等）
    ///   - encoder: 用于编码的编码器，默认为 JSONEncoder
    /// - Throws: 写入失败时抛出对应错误
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

    /// 读取文件的扩展属性（xattr）
    ///
    /// 从指定扩展属性 key 中读取数据，并自动解码为对应类型。支持任意 `Decodable` 类型，默认使用 JSONDecoder 进行解码。
    ///
    /// - Parameters:
    ///   - path: （废弃）参数，当前方法使用 URL 自带路径，传入无效
    ///   - key: 扩展属性的 key
    ///   - type: 目标类型，指定读取数据的类型
    ///   - decoder: 用于解码的解码器，默认为 JSONDecoder
    /// - Returns: 解析后的对应类型数据
    /// - Throws: 读取或解码失败时抛出对应错误
    func getXattr<T: Decodable>(
        path _: String,
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

    /// 可空
    func getXattrOrNil<T: Decodable>(
        path _: String,
        key: String,
        as type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T? {
        return try? getXattr(path: path, key: key, as: type, decoder: decoder)
    }
}
