//
//  Demo.swift
//  xxf_ios
//
//  零反射 JSON 装饰器：struct / class / enum / 嵌套 / Adapter 各场景示例
//
//  ## API 概览
//
//  ```
//  @CodingDefault<Provider>   ← 缺失 / null / 类型不匹配时回退到 Provider.defaultValue
//  @CodingDate                ← ISO8601 / 时间戳日期（Date 或 Date?）
//  @CodingLenient             ← 基础类型互转（"123" ↔ 123 等）
//  @CodingBy<Adapter>         ← 自定义 (反)序列化
//  ```
//
//  ## 限制（零反射设计的代价）
//
//  1. **装饰器不能堆叠**。每个字段最多一个装饰器。需要组合行为（如 ISO8601 + 缺失兜底）
//     写一个自定义 `CodingAdapter` 实现
//  2. **key 别名**不能用装饰器表达，手写 `init(from:)` + `decode(_:forKeys:)` helper
//  3. **忽略字段**用原生 `CodingKeys` 枚举排除，不用装饰器
//
//  Created by xxf
//

#if DEBUG

import Foundation

// MARK: - 1. enum + 自定义 Provider

public enum DemoOrderStatus: String, Codable {
    case pending, paid, shipped, completed, canceled, unknown
}

/// 自定义枚举默认值
public enum DefaultOrderStatus: CodingDefaultValueProvider {
    public static let defaultValue: DemoOrderStatus = .unknown
}

// MARK: - 2. 最简 struct

/// 最常见场景：全部字段用 @CodingDefault，缺失 / null / 类型错 都自动兜底
public struct DemoSimpleUser: Codable {
    @CodingDefault<EmptyString> public var name: String
    @CodingDefault<EmptyInt> public var age: Int
    @CodingDefault<False> public var isVip: Bool
}

// MARK: - 3. 完整 struct（展示各装饰器独立使用）

public struct DemoUser: Codable {

    @CodingDefault<EmptyString>
    public var name: String

    @CodingDefault<EmptyInt>
    public var age: Int

    /// 枚举未知 case 自动兜底
    @CodingDefault<DefaultOrderStatus>
    public var status: DemoOrderStatus

    /// 空数组兜底
    @CodingDefault<EmptyArray<String>>
    public var tags: [String]

    /// 空字典兜底
    @CodingDefault<EmptyDict<String, String>>
    public var extras: [String: String]

    /// ISO8601 日期（field 是 Optional，缺失自动 nil）
    @CodingDate
    public var createdAt: Date?

    /// ISO8601 日期（非 Optional，缺失会抛错 —— 用 `= 默认值` 只是占位，实际解码依赖 JSON 存在）
    @CodingDate
    public var updatedAt: Date = .distantPast

    /// 类型宽松（"25" → 25），缺失会抛错 —— 如需缺失兜底，改成 Int? 或自己写 Adapter
    @CodingLenient
    public var score: Int = 0

    /// 本地字段：用原生 CodingKeys 排除
    public var isSelected: Bool = false

    enum CodingKeys: String, CodingKey {
        case name, age, status, tags, extras
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case score
        // isSelected 不列进来 → 自动不参与 Codable
    }
}

// MARK: - 4. 嵌套模型

public struct DemoProduct: Codable {
    @CodingDefault<EmptyString> public var id: String
    @CodingDefault<EmptyString> public var title: String
    @CodingDefault<EmptyDouble> public var price: Double
}

public struct DemoOrder: Codable {

    @CodingDefault<EmptyString> public var orderId: String
    @CodingDefault<DefaultOrderStatus> public var status: DemoOrderStatus

    /// 嵌套数组
    @CodingDefault<EmptyArray<DemoProduct>> public var products: [DemoProduct]

    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case status, products
    }
}

// MARK: - 5. @CodingBy<Adapter>

/// 适配 "0" / "1" / "yes" / "true" / 0/1 → Bool
public struct DemoStringBoolAdapter: CodingAdapter {
    public static func decode(from decoder: Decoder) throws -> Bool {
        let c = try decoder.singleValueContainer()
        if let b = try? c.decode(Bool.self) { return b }
        if let s = try? c.decode(String.self) {
            let low = s.lowercased()
            return ["1", "true", "yes", "y"].contains(low)
        }
        if let i = try? c.decode(Int.self) { return i != 0 }
        return false
    }

    public static func encode(_ value: Bool, to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(value ? "1" : "0")
    }
}

/// 演示：用户需要 "ISO8601 + 缺失兜底" 时，不能堆叠，自己写一个 Adapter
public struct DemoDateOrDistantPastAdapter: CodingAdapter {
    public static func decode(from decoder: Decoder) throws -> Date {
        (try? ISO8601DateAdapter.decode(from: decoder)) ?? .distantPast
    }

    public static func encode(_ value: Date, to encoder: Encoder) throws {
        try ISO8601DateAdapter.encode(value, to: encoder)
    }
}

/// 缺失 key 也要兜底：为自定义 Adapter 添加 KeyedDecodingContainer 重载
public extension KeyedDecodingContainer {
    func decode(_ type: CodingBy<DemoDateOrDistantPastAdapter>.Type, forKey key: Key) throws -> CodingBy<DemoDateOrDistantPastAdapter> {
        try decodeIfPresent(type, forKey: key) ?? CodingBy(wrappedValue: .distantPast)
    }
}

public struct DemoPaymentRecord: Codable {

    @CodingBy<DemoStringBoolAdapter>
    public var isPaid: Bool = false

    /// "ISO8601 + 缺失兜底" 组合：走自定义 Adapter
    @CodingBy<DemoDateOrDistantPastAdapter>
    public var payTime: Date = .distantPast

    @CodingLenient
    public var amount: Double = 0

    enum CodingKeys: String, CodingKey {
        case isPaid = "paid"
        case payTime = "pay_time"
        case amount
    }
}

// MARK: - 6. class 场景

public final class DemoUserClass: Codable {

    @CodingDefault<EmptyString>
    public var id: String = ""

    @CodingDefault<EmptyString>
    public var name: String = ""

    @CodingLenient
    public var age: Int = 0

    // 所有属性都有默认值 → Swift 自动生成 init() 和 init(from:)
}

// MARK: - 7. Alt key 场景：手写 init(from:) + Container+Decode.swift helper

/// 后端 key 可能是 id / ID / Id / user_id 中任何一个时，手写 init(from:)
public struct DemoAltKeyUser: Codable {

    public var id: String
    public var name: String

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyKey.self)
        self.id = try c.decode(String.self, forKey: "id", "ID", "Id", "user_id")
        self.name = try c.decode(String.self, forKey: "name", "userName", "user_name")
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: AnyKey.self)
        try c.encode(id, forKey: AnyKey(stringValue: "id"))
        try c.encode(name, forKey: AnyKey(stringValue: "name"))
    }
}

// MARK: - 8. 组合使用场景

/*
 零反射设计下装饰器不能堆叠（Swift 类型系统限制）。
 但业务常需要组合多种行为，统一通过自定义 CodingAdapter 封装：

 组合模式：
 - 行为 A + 行为 B = 一个 Adapter 串联两者
 - + 缺失 key 兜底 = 给 CodingBy<MyAdapter> 加 KeyedDecodingContainer 重载
 */

// MARK: 组合 A：宽松类型 + 缺失兜底（返回 0）

public struct LenientIntOrZeroAdapter: CodingAdapter {
    public typealias Value = Int
    public static func decode(from decoder: Decoder) throws -> Int {
        (try? LenientAdapter<Int>.decode(from: decoder)) ?? 0
    }
    public static func encode(_ value: Int, to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(value)
    }
}

/// 缺失 key 时兜底
public extension KeyedDecodingContainer {
    func decode(_ type: CodingBy<LenientIntOrZeroAdapter>.Type, forKey key: Key) throws -> CodingBy<LenientIntOrZeroAdapter> {
        try decodeIfPresent(type, forKey: key) ?? CodingBy(wrappedValue: 0)
    }
}

// MARK: 组合 B：alt key + 宽松类型 + 默认值（手写 init(from:)）

public struct DemoCombinedUser: Codable {

    public var id: String            // alt keys: id / ID / user_id
    public var age: Int              // alt keys + lenient + default 0
    public var createdAt: Date       // alt keys + ISO8601 + default distantPast
    public var tags: [String]        // alt keys + empty array default

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyKey.self)

        // alt keys + default
        self.id = (try? c.decodeIfPresent(String.self, forKey: "id", "ID", "user_id")) ?? ""

        // alt keys + lenient + default: 先按顺序找 key，再用 LenientAdapter 解值
        self.age = Self.decodeLenient(c, keys: ["age", "Age", "user_age"], default: 0)

        // alt keys + ISO8601 + default
        self.createdAt = Self.decodeDate(c, keys: ["created_at", "createdAt"], default: .distantPast)

        // alt keys + empty array default
        self.tags = (try? c.decodeIfPresent([String].self, forKey: "tags", "Tags", "user_tags")) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: AnyKey.self)
        try c.encode(id, forKey: AnyKey(stringValue: "id"))
        try c.encode(age, forKey: AnyKey(stringValue: "age"))
        try c.encode(_DateParsing.encodeISO8601(createdAt), forKey: AnyKey(stringValue: "created_at"))
        try c.encode(tags, forKey: AnyKey(stringValue: "tags"))
    }

    /// 辅助：alt keys + 宽松类型 + 默认值
    private static func decodeLenient<T: Codable & LenientDecodable>(
        _ c: KeyedDecodingContainer<AnyKey>, keys: [String], default defValue: T
    ) -> T {
        for k in keys {
            let key = AnyKey(stringValue: k)
            guard c.contains(key) else { continue }
            if let sub = try? c.superDecoder(forKey: key),
               let v = try? LenientAdapter<T>.decode(from: sub) {
                return v
            }
        }
        return defValue
    }

    /// 辅助：alt keys + ISO8601 + 默认值
    private static func decodeDate(
        _ c: KeyedDecodingContainer<AnyKey>, keys: [String], default defValue: Date
    ) -> Date {
        for k in keys {
            let key = AnyKey(stringValue: k)
            guard c.contains(key) else { continue }
            if let sub = try? c.superDecoder(forKey: key),
               let v = try? ISO8601DateAdapter.decode(from: sub) {
                return v
            }
        }
        return defValue
    }
}

// MARK: 组合 C：@CodingBy 使用组合 Adapter

public struct DemoCombinedPayment: Codable {
    /// 单个字段同时要：宽松类型 + 缺失兜底，走 `LenientIntOrZeroAdapter`
    @CodingBy<LenientIntOrZeroAdapter>
    public var retryCount: Int = 0

    /// ISO8601 + 缺失兜底，走 `DemoDateOrDistantPastAdapter`
    @CodingBy<DemoDateOrDistantPastAdapter>
    public var settledAt: Date = .distantPast

    enum CodingKeys: String, CodingKey {
        case retryCount = "retry_count"
        case settledAt = "settled_at"
    }
}

// MARK: - 9. Foundation 类型（URL / UUID / Data / Decimal）

/// 常见 Foundation 类型的默认值 / 宽松解析示例
public struct DemoFoundation: Codable {

    /// URL?：缺失 / null / 非法 URL → nil
    @CodingDefault<EmptyURL>
    public var avatar: URL?

    /// URL：后端可能传 "https://..." 字符串，空串 / 非法也 OK
    @CodingBy<URLAdapter>
    public var website: URL?

    /// UUID：缺失时用 null UUID（全 0）
    @CodingDefault<EmptyUUID>
    public var id: UUID

    /// UUID 宽松解析（字符串 → UUID）
    @CodingLenient
    public var sessionId: UUID? = nil

    /// Data（base64 字符串）
    @CodingBy<Base64DataAdapter>
    public var payload: Data = Data()

    /// Decimal（金额）：后端传字符串也 OK
    @CodingLenient
    public var amount: Decimal = 0

    /// Decimal 默认值
    @CodingDefault<EmptyDecimal>
    public var balance: Decimal

    /// Optional Int 宽松：后端传 "42" 也解
    @CodingLenient
    public var score: Int? = nil
}

// MARK: - 10. 运行时测试

public enum DemoJSONCodableSamples {

    public static func runAll() {
        print("====== Demo Start ======")
        testSimple()
        testUser()
        testUnknownEnum()
        testNested()
        testAdapter()
        testClass()
        testAltKey()
        testCombined()
        testFoundation()
        print("====== Demo End ======")
    }

    public static func testSimple() {
        let json = #"{"name":"Alice","age":20}"#.data(using: .utf8)!
        let u = try? JSONDecoder().decode(DemoSimpleUser.self, from: json)
        print("✓ Simple:", u!)
    }

    public static func testUser() {
        let json = #"""
        {
            "name": "Alice",
            "age": 25,
            "status": "paid",
            "tags": ["gold"],
            "created_at": "2021-04-18T10:30:00.000Z",
            "updated_at": "2021-04-18T10:30:00.000Z",
            "score": "88"
        }
        """#.data(using: .utf8)!
        let u = try? JSONDecoder().decode(DemoUser.self, from: json)
        print("✓ User:", u!)
    }

    public static func testUnknownEnum() {
        let json = #"""
        {"status":"future_case_xxx","updated_at":"2021-01-01T00:00:00Z","score":0}
        """#.data(using: .utf8)!
        let u = try? JSONDecoder().decode(DemoUser.self, from: json)
        print("✓ Unknown enum → .unknown:", u?.status as Any)
    }

    public static func testNested() {
        let json = #"""
        {
            "order_id": "O_123",
            "status": "shipped",
            "products": [
                { "id": "p1", "title": "book", "price": 39.9 },
                { "id": "p2", "title": "pen", "price": 9.9 }
            ]
        }
        """#.data(using: .utf8)!
        let order = try? JSONDecoder().decode(DemoOrder.self, from: json)
        print("✓ Order:", order!)
    }

    public static func testAdapter() {
        // pay_time 故意缺失 → 走自定义 Adapter 的 "distantPast" 兜底
        let json = #"{"paid":"1","amount":"99.99"}"#.data(using: .utf8)!
        let r = try? JSONDecoder().decode(DemoPaymentRecord.self, from: json)
        print("✓ Payment:", r!)
    }

    public static func testClass() {
        let json = #"{"id":"c_1","name":"Carol","age":"28"}"#.data(using: .utf8)!
        let u = try? JSONDecoder().decode(DemoUserClass.self, from: json)
        print("✓ Class:", u!)
    }

    public static func testAltKey() {
        let json = #"{"ID":"u_1","user_name":"Dave"}"#.data(using: .utf8)!
        let u = try? JSONDecoder().decode(DemoAltKeyUser.self, from: json)
        print("✓ AltKey:", u!)
    }

    public static func testCombined() {
        // 全部 key 的别名、类型混乱、部分缺失
        let json = #"""
        {
            "ID": "u_combined",
            "Age": "30",
            "createdAt": "2021-05-01 08:00:00",
            "user_tags": ["a", "b"]
        }
        """#.data(using: .utf8)!
        let u = try? JSONDecoder().decode(DemoCombinedUser.self, from: json)
        print("✓ Combined:", u!)
    }

    public static func testFoundation() {
        // URL / UUID / Data / Decimal 各场景
        let json = #"""
        {
            "avatar": "https://example.com/a.png",
            "website": "  not a url  ",
            "id": "01234567-89AB-CDEF-0123-456789ABCDEF",
            "sessionId": "ABCDEF01-2345-6789-ABCD-EF0123456789",
            "payload": "SGVsbG8=",
            "amount": "123.456789",
            "balance": "99.99",
            "score": "42"
        }
        """#.data(using: .utf8)!
        let f = try? JSONDecoder().decode(DemoFoundation.self, from: json)
        print("✓ Foundation:", f!)
    }
}

#endif
