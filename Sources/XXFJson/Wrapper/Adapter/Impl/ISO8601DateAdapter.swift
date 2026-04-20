//
//  ISO8601DateAdapter.swift
//  xxf_ios
//
//  ISO8601 日期 / 混合时间戳适配器
//
//  Created by xxf
//

import Foundation

/// ISO8601 日期 / 混合时间戳适配器（非可选 `Date`）
///
/// 覆盖后端常见写法：
/// - `"2021-04-18T10:30:00Z"`
/// - `"2021-04-18T10:30:00.123Z"`
/// - `"2021-04-18T10:30:00+08:00"`
/// - `"2021-04-18 10:30:00"`
/// - `"2021-04-18"`
/// - `1744966200`（秒级时间戳）
/// - `1744966200000`（毫秒级时间戳）
/// - 字符串形式的数字时间戳
///
/// 编码时输出带毫秒的 ISO8601 字符串。
///
/// ## 使用
///
/// ```swift
/// struct Event: Codable {
///     @CodingBy<ISO8601DateAdapter>
///     var startAt: Date = .distantPast
/// }
/// ```
///
/// 简写：`@CodingDate` 等价于 `@CodingBy<ISO8601DateAdapter>`
public struct ISO8601DateAdapter: CodingAdapter {

    public typealias Value = Date

    public static func decode(from decoder: Decoder) throws -> Date {
        let c = try decoder.singleValueContainer()

        if let s = try? c.decode(String.self), let d = _DateParsing.parseString(s) {
            return d
        }
        if let ts = try? c.decode(Double.self) {
            return _DateParsing.dateFromTimestamp(ts)
        }
        if let ts = try? c.decode(Int64.self) {
            return _DateParsing.dateFromTimestamp(Double(ts))
        }
        if let ts = try? c.decode(Int.self) {
            return _DateParsing.dateFromTimestamp(Double(ts))
        }

        throw DecodingError.typeMismatch(Date.self, .init(
            codingPath: decoder.codingPath,
            debugDescription: "ISO8601DateAdapter failed to parse date (neither an ISO string nor a timestamp)"
        ))
    }

    public static func encode(_ value: Date, to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(_DateParsing.encodeISO8601(value))
    }
}
