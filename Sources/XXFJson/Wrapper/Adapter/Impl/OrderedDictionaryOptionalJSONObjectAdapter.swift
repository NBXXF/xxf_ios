//
//  OrderedDictionaryOptionalJSONObjectAdapter.swift
//  xxf_ios
//
//  Created by xxf.
//

import Foundation
import OrderedCollections

/// 可选版本：`nil`/`null` 透传；非空值走 `OrderedDictionaryJSONObjectAdapter`。
/// - 解码支持：
///   - `null`
///   - object: `{"a": {...}, "b": {...}}`
///   - 交替数组: `["a", {...}, "b", {...}]`
/// - 编码统一输出：
///   - `nil` -> `null`
///   - 非空 -> object
public struct OrderedDictionaryOptionalJSONObjectAdapter<Element: Codable>: CodingAdapter {
    public typealias Value = OrderedDictionary<String, Element>?

    public static func decode(from decoder: Decoder) throws -> Value {
        // 明确区分 `null` 与“有值对象/数组”：
        // - `null` => nil
        // - 非 null => 交给非可选适配器继续做双格式解析
        if let container = try? decoder.singleValueContainer(), container.decodeNil() {
            return nil
        }
        return try OrderedDictionaryJSONObjectAdapter<Element>.decode(from: decoder)
    }

    public static func encode(_ value: Value, to encoder: Encoder) throws {
        guard let value else {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
            return
        }
        try OrderedDictionaryJSONObjectAdapter<Element>.encode(value, to: encoder)
    }
}

// MARK: - Key Missing Fallback

extension KeyedDecodingContainer {
    /// `@CodingBy<OrderedDictionaryOptionalJSONObjectAdapter<...>> var x: OrderedDictionary<String, T>?`
    /// 在 key 缺失时默认返回 `nil`。
    public func decode<Element>(
        _ type: CodingBy<OrderedDictionaryOptionalJSONObjectAdapter<Element>>.Type,
        forKey key: Key
    ) throws -> CodingBy<OrderedDictionaryOptionalJSONObjectAdapter<Element>> where Element: Codable {
        // `decodeIfPresent` 可同时覆盖“字段缺失”与显式 `null`，符合可选语义。
        try decodeIfPresent(type, forKey: key) ?? CodingBy(wrappedValue: nil)
    }
}
