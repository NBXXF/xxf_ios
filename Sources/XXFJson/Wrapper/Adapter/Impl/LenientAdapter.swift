//
//  LenientAdapter.swift
//  xxf_ios
//
//  类型宽松转换适配器
//
//  Created by xxf
//

import Foundation

/// 宽松类型适配器
///
/// 后端偶发把字段写成另一种基础类型时自动转换：
/// - `"123"` → `123`
/// - `1` → `true`
/// - `true` → `"true"`
///
/// ## 使用
///
/// ```swift
/// struct User: Codable {
///     @CodingBy<LenientAdapter<Int>>
///     var id: Int = 0
/// }
/// ```
///
/// 简写：`@CodingLenient` 等价于 `@CodingBy<LenientAdapter<T>>`
///
/// - Note: 仅支持实现了 `LenientDecodable` 的类型（本库内置基础类型）
public struct LenientAdapter<T: Codable & LenientDecodable>: CodingAdapter {

    public typealias Value = T

    public static func decode(from decoder: Decoder) throws -> T {
        let c = try decoder.singleValueContainer()
        // 1. 原生解码
        if let v = try? c.decode(T.self) { return v }
        // 2. 逐个尝试基础类型并转换
        if let b = try? c.decode(Bool.self), let v = T.lenientDecode(b) { return v }
        if let i = try? c.decode(Int64.self), let v = T.lenientDecode(i) { return v }
        if let d = try? c.decode(Double.self), let v = T.lenientDecode(d) { return v }
        if let s = try? c.decode(String.self), let v = T.lenientDecode(s) { return v }

        throw DecodingError.typeMismatch(T.self, .init(
            codingPath: decoder.codingPath,
            debugDescription: "LenientAdapter 无法将 JSON 值转换为 \(T.self)"
        ))
    }

    public static func encode(_ value: T, to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(value)
    }
}
