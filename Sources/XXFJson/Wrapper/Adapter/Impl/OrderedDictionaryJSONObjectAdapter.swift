//
//  OrderedDictionaryJSONObjectAdapter.swift
//  xxf_ios
//
//  Created by xxf.
//

import Foundation
import OrderedCollections

/// 兼容 `OrderedDictionary<String, Element>` 的 JSON 适配器：
/// - 解码支持两种输入：
///   1) object: `{"a": {...}, "b": {...}}`
///   2) 交替数组: `["a", {...}, "b", {...}]`
/// - 编码统一输出 object：`{"a": {...}, "b": {...}}`
/// - 关键兼容点：必须规避全局 key strategy 对“动态业务 key”的改写。
///   - 错误做法：`container(keyedBy:)` + 动态 CodingKey，在
///     `convertFromSnakeCase/convertToSnakeCase` 下会把 `"source_asset_id"`
///     改写成 `"sourceAssetId"`。
///   - 本实现：object 路径统一走 `[String: Element]` 的 single-value 解码/编码，
///     保证 map key 原样透传，仅字段模型内的静态 `CodingKeys` 继续按 strategy 生效。
public struct OrderedDictionaryJSONObjectAdapter<Element: Codable>: CodingAdapter {
    public typealias Value = OrderedDictionary<String, Element>

    public static func decode(from decoder: Decoder) throws -> Value {
        // 先尝试 object 路径（主流格式）：
        // 1) 输入是 object 时，直接成功并保留原始业务 key。
        // 2) 输入是数组时，会在此分支抛出“顶层类型不匹配”，再回退到交替数组分支。
        //
        // 注意：只对“顶层不是 object”做回退。
        // 如果 object 内部数据损坏（例如 element 结构错误），必须把原始错误抛给上层，
        // 不能静默切到数组分支后丢失真实报错上下文。
        do {
            return try decodeObjectWithoutKeyTransform(from: decoder)
        } catch let DecodingError.typeMismatch(type, _) where type == [String: Element].self {
            return try decodeAlternatingArray(from: decoder)
        }
        catch {
            throw error
        }
    }

    public static func encode(_ value: Value, to encoder: Encoder) throws {
        // 编码始终输出 object，并通过 `[String: Element]` 路径规避
        // `keyEncodingStrategy` 改写动态 map key。
        //
        // 例如业务 key `"sourceAssetID"` 在 convertToSnakeCase 下也必须保持原样，
        // 否则会与服务端约定的动态 key 不一致。
        var object: [String: Element] = [:]
        object.reserveCapacity(value.count)
        for (key, element) in value {
            object[key] = element
        }
        var container = encoder.singleValueContainer()
        try container.encode(object)
    }

    private static func decodeObjectWithoutKeyTransform(from decoder: Decoder) throws -> Value {
        // 关键点：decode `[String: Element]` 时，map key 不参与 keyDecodingStrategy，
        // 只对 Element 内部字段应用 strategy。
        let container = try decoder.singleValueContainer()
        let object = try container.decode([String: Element].self)

        // 转为 OrderedDictionary，保留解码得到的迭代顺序。
        // 注意：JSON object 的键顺序不是规范保证，只能“尽力保持输入顺序”。
        var ordered: Value = [:]
        ordered.reserveCapacity(object.count)
        for (key, element) in object {
            ordered[key] = element
        }
        return ordered
    }

    private static func decodeAlternatingArray(from decoder: Decoder) throws -> Value {
        // 兼容历史/非标准格式：["k1", v1, "k2", v2, ...]
        var container = try decoder.unkeyedContainer()
        var ordered: Value = [:]
        if let count = container.count {
            ordered.reserveCapacity(count / 2)
        }

        while !container.isAtEnd {
            let key = try container.decode(String.self)
            guard !container.isAtEnd else {
                // 必须成对出现：key 后必须紧跟 value。
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "OrderedDictionary alternating array is missing value for key: \(key)"
                    )
                )
            }

            if ordered[key] != nil {
                // 交替数组格式下重复 key 会导致覆盖歧义，直接按损坏数据处理。
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Duplicate key in OrderedDictionary alternating array: \(key)"
                    )
                )
            }

            ordered[key] = try container.decode(Element.self)
        }

        return ordered
    }
}
