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
///
/// ## 与「枚举自己重写 `init(from:)`」方案的区别
///
/// 针对**自定义枚举**的未知值兜底，有两种常见写法：
///
/// **A. 枚举内重写 `init(from:)`（类型自带兜底）**
/// ```swift
/// extension Status {
///     init(from decoder: Decoder) throws {
///         let raw = try decoder.singleValueContainer().decode(String.self)
///         self = Self(rawValue: raw) ?? .unknown
///     }
/// }
/// ```
///
/// **B. `@CodingDefault<Provider>`（字段级兜底）**
/// ```swift
/// @CodingDefault<DefaultStatusProvider> var status: Status
/// ```
///
/// | 维度 | A. 枚举 `init(from:)` | B. `@CodingDefault` |
/// | --- | --- | --- |
/// | 适用类型 | **仅自定义类型**（基本类型 `String`/`Int`/`Bool` 的 Codable 无法被 extension 覆盖） | **任意类型**（基本类型、集合、枚举、自定义模型） |
/// | 兜底范围 | 该类型**所有使用场景**（数组、字典、嵌套、可选、直接解码）都自动生效 | **仅被包装的字段**生效；裸用 `[Status]`、嵌套字段漏加包装器则不生效 |
/// | key 缺失 / null | 处理不了（外层容器先抛 `keyNotFound`，进不到 `init(from:)`） | ✅ 通过 `KeyedDecodingContainer` 重载统一兜底 |
/// | 类型不匹配（`"1"` ↔ `1`） | 需在 `init(from:)` 里手写多类型尝试 | ✅ 泛型 `decode` 失败自动回落默认值 |
/// | 默认值灵活度 | 全局一个默认值，写死在枚举里 | 同一类型可在不同字段配不同 `Provider` |
/// | 对类型的侵入 | 改动枚举本身 | 枚举保持纯净，策略在字段上声明 |
///
/// ### 选型建议
///
/// - **基本类型 / 集合 / 字段缺失 / 类型容错** → 必须用 `@CodingDefault`
///   （Swift 禁止 extension 覆盖 `String`/`Int` 等已有 Codable 实现）
/// - **自定义枚举想要"哪里用都不会崩"** → 在枚举里重写 `init(from:)`，保证兜底
/// - **既想安全、又想字段级可配置默认值** → 两者叠加：枚举内 `init(from:)` 做兜底，
///   字段上再用 `@CodingDefault` 指定该字段独有的默认值
///
/// > 小结：`init(from:)` 是**类型自带的安全网**，`@CodingDefault` 是**字段级的策略装饰器**，
/// > 二者互补而非互斥。项目里通常并存使用。
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
