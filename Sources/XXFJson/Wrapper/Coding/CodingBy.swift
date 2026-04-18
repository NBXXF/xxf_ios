//
//  CodingBy.swift
//  xxf_ios
//
//  @CodingBy<Adapter> —— 自定义适配器装饰器
//
//  Created by xxf
//

import Foundation

/// 自定义适配器装饰器
///
/// 指定 `Adapter` 后，字段的值 (反)序列化完全由 Adapter 接管。
///
/// ## 使用
///
/// ```swift
/// struct User: Codable {
///     @CodingBy<StringBoolAdapter> var isVip: Bool = false
/// }
/// ```
///
/// - Note: 要处理 "key 缺失" 场景，为自定义 Adapter 增加
///   `KeyedDecodingContainer.decode(_:forKey:)` 重载
@propertyWrapper
public struct CodingBy<Adapter: CodingAdapter>: Codable {

    public typealias Value = Adapter.Value

    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        self.wrappedValue = try Adapter.decode(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try Adapter.encode(wrappedValue, to: encoder)
    }
}
