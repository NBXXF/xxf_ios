//
//  CodingDate.swift
//  xxf_ios
//
//  @CodingDate —— ISO8601 / 时间戳日期装饰器（零反射）
//
//  内部委托 `ISO8601DateAdapter` / `ISO8601OptionalDateAdapter`
//
//  Created by xxf
//

import Foundation

/// ISO8601 / 时间戳日期装饰器
///
/// 支持：
/// - ISO8601 字符串（带 / 不带毫秒）
/// - 秒级 / 毫秒级时间戳（数字或字符串）
/// - 常见非标准格式（见 `_DateParsing.fallbackFormatters`）
///
/// ## 使用
///
/// ```swift
/// struct Event: Codable {
///     @CodingDate var startAt: Date = .distantPast
///     @CodingDate var endAt: Date?                   // 可选版本
/// }
/// ```
///
/// ## 堆叠
///
/// 需要"缺失 key 也兜底"时，外层叠加 `@CodingDefault`：
///
/// ```swift
/// @CodingDefault<DistantPast>
/// @CodingDate
/// var startAt: Date
/// ```
///
/// - Note: `@CodingDate` 等价于 `@CodingBy<ISO8601DateAdapter>`；
///   对 `Date?` 字段，等价于 `@CodingBy<ISO8601OptionalDateAdapter>`
@propertyWrapper
public struct CodingDate<Value: Codable>: Codable {

    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        if Value.self == Date.self {
            self.wrappedValue = try ISO8601DateAdapter.decode(from: decoder) as! Value
        } else if Value.self == Date?.self {
            self.wrappedValue = try ISO8601OptionalDateAdapter.decode(from: decoder) as! Value
        } else {
            // 非 Date 类型：透传（理论上用户不该这么写，但给个兜底）
            let c = try decoder.singleValueContainer()
            self.wrappedValue = try c.decode(Value.self)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let date = wrappedValue as? Date {
            try ISO8601DateAdapter.encode(date, to: encoder)
        } else if let optDate = wrappedValue as? Date? {
            try ISO8601OptionalDateAdapter.encode(optDate, to: encoder)
        } else {
            var c = encoder.singleValueContainer()
            try c.encode(wrappedValue)
        }
    }
}

// MARK: - KeyedDecodingContainer 重载：Date? 字段 key 缺失自动 nil

public extension KeyedDecodingContainer {

    /// `@CodingDate var x: Date?` 缺 key 时回退为 `nil`
    ///
    /// - Note: Swift 把 `CodingDate<Date?>` 当非 Optional 处理，合成 `init(from:)`
    ///   会用 `decode`（而不是 `decodeIfPresent`），导致缺 key 抛错。本重载修正该行为。
    func decode(_ type: CodingDate<Date?>.Type, forKey key: Key) throws -> CodingDate<Date?> {
        try decodeIfPresent(type, forKey: key) ?? CodingDate(wrappedValue: nil)
    }
}
