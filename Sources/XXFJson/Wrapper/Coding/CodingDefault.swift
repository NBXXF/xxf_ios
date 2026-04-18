//
//  CodingDefault.swift
//  xxf_ios
//
//  @CodingDefault —— 类型级默认值装饰器（零反射）
//
//  Created by xxf
//

import Foundation

/// 默认值装饰器
///
/// 以下情况回退到 `Provider.defaultValue`：
/// 1. key 不存在
/// 2. 值为 JSON `null`
/// 3. 类型不匹配（后端偶发把 Int 写成 String 等）
/// 4. 枚举 raw value 未知
///
/// ## 使用
///
/// ```swift
/// struct User: Codable {
///     @CodingDefault<EmptyString> var name: String
///     @CodingDefault<EmptyInt> var age: Int
///     @CodingDefault<False> var isVip: Bool
///     @CodingDefault<EmptyArray<String>> var tags: [String]
///     @CodingDefault<EmptyDict<String, String>> var extras: [String: String]
///     @CodingDefault<DefaultOrderStatus> var status: OrderStatus  // 用户自定义
/// }
///
/// enum DefaultOrderStatus: DefaultValueProvider {
///     static let defaultValue: OrderStatus = .unknown
/// }
/// ```
///
/// ## 实现说明
///
/// - 通过泛型 `Provider` 把默认值提升到**类型级别**，`init(from:)` 里可以直接
///   访问 `Provider.defaultValue`，无需 Mirror 反射
/// - 通过 `KeyedDecodingContainer.decode(_:forKey:)` 重载，把 "key 缺失" 也纳入
///   fallback 逻辑
@propertyWrapper
public struct CodingDefault<Provider: CodingDefaultValueProvider>: Codable {

    public typealias Value = Provider.Value

    public var wrappedValue: Value

    // MARK: - Init

    /// 无参初始化：直接使用 Provider 的默认值（给 KeyedDecodingContainer 的重载用）
    public init() {
        self.wrappedValue = Provider.defaultValue
    }

    /// 带初值初始化：支持 `var x: T = initial` 语法
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        // null / 缺失 / 类型不匹配 都回退到默认值
        if c.decodeNil() {
            self.wrappedValue = Provider.defaultValue
        } else if let v = try? c.decode(Value.self) {
            self.wrappedValue = v
        } else {
            self.wrappedValue = Provider.defaultValue
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(wrappedValue)
    }
}

// MARK: - KeyedDecodingContainer 重载：让 key 缺失也触发 fallback

public extension KeyedDecodingContainer {

    /// 当 JSON 里没有该 key 时，直接返回 Provider 默认值构造的 `CodingDefault`，
    /// 而不是抛 `keyNotFound` 错误
    func decode<P>(_ type: CodingDefault<P>.Type, forKey key: Key) throws -> CodingDefault<P> {
        try decodeIfPresent(type, forKey: key) ?? CodingDefault<P>()
    }
}
