//
//  URLAdapter.swift
//  xxf_ios
//
//  宽松 URL 适配器：空串 / 非法 URL 自动回退为 nil
//
//  Created by xxf
//

import Foundation

/// 宽松 URL 适配器（可选版本）
///
/// 行为：
/// - JSON `null` → `nil`
/// - 空字符串 → `nil`（原生 URL 解析会失败，这里直接 nil）
/// - 非法 URL 字符串 → `nil`（不抛错）
/// - 合法 URL 字符串 → `URL`
///
/// ## 使用
///
/// ```swift
/// struct User: Codable {
///     @CodingBy<URLAdapter> var avatar: URL?
/// }
/// ```
///
/// 简写：对 `URL?` 字段也可以用 `@CodingLenient var avatar: URL?`（走 `LenientAdapter` +
/// `URL: LenientDecodable` 的自动链路），行为等价
public struct URLAdapter: CodingAdapter {

    public typealias Value = URL?

    public static func decode(from decoder: Decoder) throws -> URL? {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { return nil }

        if let s = try? c.decode(String.self) {
            let trimmed = s.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return nil }
            return URL(string: trimmed)
        }
        // 已是 URL 类型（罕见路径）
        if let u = try? c.decode(URL.self) { return u }
        return nil
    }

    public static func encode(_ value: URL?, to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        if let url = value {
            try c.encode(url.absoluteString)
        } else {
            try c.encodeNil()
        }
    }
}

// MARK: - KeyedDecodingContainer 重载：key 缺失自动 nil

public extension KeyedDecodingContainer {
    /// `@CodingBy<URLAdapter> var x: URL?` key 缺失时自动 nil
    func decode(_ type: CodingBy<URLAdapter>.Type, forKey key: Key) throws -> CodingBy<URLAdapter> {
        try decodeIfPresent(type, forKey: key) ?? CodingBy(wrappedValue: nil)
    }
}
