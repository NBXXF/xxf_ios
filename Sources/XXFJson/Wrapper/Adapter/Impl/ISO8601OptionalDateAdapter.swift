//
//  ISO8601OptionalDateAdapter.swift
//  xxf_ios
//
//  ISO8601 可选日期适配器：`null` / 解析失败 → `nil`
//
//  Created by xxf
//

import Foundation

/// ISO8601 日期适配器（可选版本）
///
/// 行为与 `ISO8601DateAdapter` 一致，但把 JSON `null` / 空串 / 无法解析的值
/// 回退为 `nil`，而不是抛错。
///
/// ## 使用
///
/// ```swift
/// struct Event: Codable {
///     @CodingBy<ISO8601OptionalDateAdapter>
///     var endAt: Date?
/// }
/// ```
///
/// 简写：对 `Date?` 字段直接用 `@CodingDate`，内部会自动选用本适配器
public struct ISO8601OptionalDateAdapter: CodingAdapter {

    public typealias Value = Date?

    public static func decode(from decoder: Decoder) throws -> Date? {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { return nil }

        if let s = try? c.decode(String.self) {
            if s.isEmpty { return nil }
            return _DateParsing.parseString(s)
        }
        if let ts = try? c.decode(Double.self) { return _DateParsing.dateFromTimestamp(ts) }
        if let ts = try? c.decode(Int64.self) { return _DateParsing.dateFromTimestamp(Double(ts)) }
        if let ts = try? c.decode(Int.self) { return _DateParsing.dateFromTimestamp(Double(ts)) }

        return nil
    }

    public static func encode(_ value: Date?, to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        if let d = value {
            try c.encode(_DateParsing.encodeISO8601(d))
        } else {
            try c.encodeNil()
        }
    }
}
