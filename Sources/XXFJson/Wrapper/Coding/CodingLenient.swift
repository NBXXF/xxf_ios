//
//  CodingLenient.swift
//  xxf_ios
//
//  @CodingLenient —— 类型宽松转换装饰器（零反射）
//
//  内部委托 `LenientAdapter<T>`
//
//  Created by xxf
//

import Foundation

/// 类型宽松转换装饰器
///
/// 自动处理常见的基础类型互转：
/// - `"123"` → `123`
/// - `1` → `true`
/// - `true` → `"true"`
///
/// ## 使用
///
/// ```swift
/// struct User: Codable {
///     @CodingLenient var id: Int = 0         // 后端传 "123" 也能解
///     @CodingLenient var isVip: Bool = false // 后端传 1 / "1" / "yes" 都行
///     @CodingLenient var score: Double = 0   // 后端传 "3.14" 也能解
/// }
/// ```
///
/// ## 堆叠
///
/// 需要"缺失 key 也兜底"时，外层叠加 `@CodingDefault`：
///
/// ```swift
/// @CodingDefault<EmptyInt>
/// @CodingLenient
/// var age: Int
/// ```
///
/// - Note: `@CodingLenient` 等价于 `@CodingBy<LenientAdapter<T>>`
/// - Note: 仅支持 `LenientDecodable` 类型（内置 Int / Int64 / Double / Bool / String）
@propertyWrapper
public struct CodingLenient<Value: Codable & LenientDecodable>: Codable {

    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        self.wrappedValue = try LenientAdapter<Value>.decode(from: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        try LenientAdapter<Value>.encode(wrappedValue, to: encoder)
    }
}
