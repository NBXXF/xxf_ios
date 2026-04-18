//
//  CodingAdapter.swift
//  xxf_ios
//
//  自定义 JSON 适配器协议
//
//  Created by xxf
//

import Foundation

/// 自定义 JSON 适配器协议
///
/// 类比 Gson 的 `TypeAdapter`：接管某个字段的 (反)序列化逻辑。
/// 实现本协议后，用 `@CodingBy<YourAdapter>` 挂到字段上即可生效。
///
/// ## 使用
///
/// ```swift
/// struct StringBoolAdapter: CodingAdapter {
///     static func decode(from decoder: Decoder) throws -> Bool {
///         let c = try decoder.singleValueContainer()
///         if let b = try? c.decode(Bool.self) { return b }
///         if let s = try? c.decode(String.self) { return s == "1" || s.lowercased() == "true" }
///         if let i = try? c.decode(Int.self) { return i != 0 }
///         return false
///     }
///     static func encode(_ value: Bool, to encoder: Encoder) throws {
///         var c = encoder.singleValueContainer()
///         try c.encode(value ? "1" : "0")
///     }
/// }
///
/// struct User: Codable {
///     @CodingBy<StringBoolAdapter> var isVip: Bool = false
/// }
/// ```
public protocol CodingAdapter {
    /// 被适配的目标类型
    associatedtype Value: Codable

    /// 自定义解码
    static func decode(from decoder: Decoder) throws -> Value

    /// 自定义编码
    static func encode(_ value: Value, to encoder: Encoder) throws
}
