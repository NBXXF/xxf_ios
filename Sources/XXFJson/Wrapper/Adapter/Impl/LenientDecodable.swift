//
//  LenientDecodable.swift
//  xxf_ios
//
//  LenientDecodable 协议 + 基础类型 / Foundation 类型 / Optional 的默认实现
//
//  Created by xxf
//

import Foundation

// MARK: - 协议

/// 类型宽松转换协议
///
/// 任何类型实现本协议即可被 `LenientAdapter` / `@CodingLenient` 适配。
///
/// 本库内置实现：
/// - 整型：`Int` / `Int8` / `Int16` / `Int32` / `Int64`
/// - 无符号：`UInt` / `UInt8` / `UInt16` / `UInt32` / `UInt64`
/// - 浮点：`Float` / `Double`
/// - 布尔：`Bool`
/// - 字符串：`String`
/// - Foundation：`URL` / `UUID` / `Decimal`
/// - `Optional<Wrapped>`（Wrapped 遵循本协议时自动支持）
public protocol LenientDecodable {
    /// 从任意 JSON 基础值构造自身；无法转换时返回 nil
    static func lenientDecode(_ any: Any) -> Self?
}

// MARK: - 有符号整型

extension Int: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> Int? {
        if let v = any as? Int { return v }
        if let v = any as? Int64 { return Int(exactly: v) }
        if let v = any as? Double { return Int(v) }
        if let v = any as? Bool { return v ? 1 : 0 }
        if let s = any as? String {
            if let i = Int(s) { return i }
            if let d = Double(s) { return Int(d) }
        }
        return nil
    }
}

extension Int8: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> Int8? {
        if let v = any as? Int8 { return v }
        if let v = any as? Int { return Int8(exactly: v) }
        if let v = any as? Int64 { return Int8(exactly: v) }
        if let v = any as? Double { return Int8(exactly: v) }
        if let v = any as? Bool { return v ? 1 : 0 }
        if let s = any as? String {
            if let i = Int8(s) { return i }
            if let d = Double(s) { return Int8(exactly: d) }
        }
        return nil
    }
}

extension Int16: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> Int16? {
        if let v = any as? Int16 { return v }
        if let v = any as? Int { return Int16(exactly: v) }
        if let v = any as? Int64 { return Int16(exactly: v) }
        if let v = any as? Double { return Int16(exactly: v) }
        if let v = any as? Bool { return v ? 1 : 0 }
        if let s = any as? String {
            if let i = Int16(s) { return i }
            if let d = Double(s) { return Int16(exactly: d) }
        }
        return nil
    }
}

extension Int32: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> Int32? {
        if let v = any as? Int32 { return v }
        if let v = any as? Int { return Int32(exactly: v) }
        if let v = any as? Int64 { return Int32(exactly: v) }
        if let v = any as? Double { return Int32(exactly: v) }
        if let v = any as? Bool { return v ? 1 : 0 }
        if let s = any as? String {
            if let i = Int32(s) { return i }
            if let d = Double(s) { return Int32(exactly: d) }
        }
        return nil
    }
}

extension Int64: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> Int64? {
        if let v = any as? Int64 { return v }
        if let v = any as? Int { return Int64(v) }
        if let v = any as? Double { return Int64(v) }
        if let v = any as? Bool { return v ? 1 : 0 }
        if let s = any as? String {
            if let i = Int64(s) { return i }
            if let d = Double(s) { return Int64(d) }
        }
        return nil
    }
}

// MARK: - 无符号整型

extension UInt: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> UInt? {
        if let v = any as? UInt { return v }
        if let v = any as? Int, v >= 0 { return UInt(v) }
        if let v = any as? Int64, v >= 0 { return UInt(exactly: v) }
        if let v = any as? UInt64 { return UInt(exactly: v) }
        if let v = any as? Double, v >= 0 { return UInt(exactly: v) }
        if let v = any as? Bool { return v ? 1 : 0 }
        if let s = any as? String, let u = UInt(s) { return u }
        return nil
    }
}

extension UInt8: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> UInt8? {
        if let v = any as? UInt8 { return v }
        if let v = any as? Int { return UInt8(exactly: v) }
        if let v = any as? Int64 { return UInt8(exactly: v) }
        if let v = any as? Double { return UInt8(exactly: v) }
        if let v = any as? Bool { return v ? 1 : 0 }
        if let s = any as? String, let u = UInt8(s) { return u }
        return nil
    }
}

extension UInt16: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> UInt16? {
        if let v = any as? UInt16 { return v }
        if let v = any as? Int { return UInt16(exactly: v) }
        if let v = any as? Int64 { return UInt16(exactly: v) }
        if let v = any as? Double { return UInt16(exactly: v) }
        if let v = any as? Bool { return v ? 1 : 0 }
        if let s = any as? String, let u = UInt16(s) { return u }
        return nil
    }
}

extension UInt32: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> UInt32? {
        if let v = any as? UInt32 { return v }
        if let v = any as? Int { return UInt32(exactly: v) }
        if let v = any as? Int64 { return UInt32(exactly: v) }
        if let v = any as? Double { return UInt32(exactly: v) }
        if let v = any as? Bool { return v ? 1 : 0 }
        if let s = any as? String, let u = UInt32(s) { return u }
        return nil
    }
}

extension UInt64: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> UInt64? {
        if let v = any as? UInt64 { return v }
        if let v = any as? Int, v >= 0 { return UInt64(v) }
        if let v = any as? Int64, v >= 0 { return UInt64(v) }
        if let v = any as? Double, v >= 0 { return UInt64(exactly: v) }
        if let v = any as? Bool { return v ? 1 : 0 }
        if let s = any as? String, let u = UInt64(s) { return u }
        return nil
    }
}

// MARK: - 浮点

extension Float: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> Float? {
        if let v = any as? Float { return v }
        if let v = any as? Double { return Float(v) }
        if let v = any as? Int { return Float(v) }
        if let v = any as? Int64 { return Float(v) }
        if let v = any as? Bool { return v ? 1 : 0 }
        if let s = any as? String, let f = Float(s) { return f }
        return nil
    }
}

extension Double: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> Double? {
        if let v = any as? Double { return v }
        if let v = any as? Float { return Double(v) }
        if let v = any as? Int { return Double(v) }
        if let v = any as? Int64 { return Double(v) }
        if let v = any as? Bool { return v ? 1 : 0 }
        if let s = any as? String, let d = Double(s) { return d }
        return nil
    }
}

// MARK: - 布尔 / 字符串

extension Bool: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> Bool? {
        if let v = any as? Bool { return v }
        if let v = any as? Int { return v != 0 }
        if let v = any as? Int64 { return v != 0 }
        if let v = any as? Double { return v != 0 }
        if let s = any as? String {
            switch s.lowercased() {
            case "true", "1", "yes", "y": return true
            case "false", "0", "no", "n", "": return false
            default: return nil
            }
        }
        return nil
    }
}

extension String: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> String? {
        if let v = any as? String { return v }
        if let v = any as? Int { return String(v) }
        if let v = any as? Int64 { return String(v) }
        if let v = any as? Double { return String(v) }
        if let v = any as? Bool { return String(v) }
        return nil
    }
}

// MARK: - Foundation 类型

extension URL: LenientDecodable {
    /// URL 宽松转换：支持字符串 / URL，非法或空串返回 nil
    public static func lenientDecode(_ any: Any) -> URL? {
        if let u = any as? URL { return u }
        if let s = any as? String {
            let trimmed = s.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return nil }
            return URL(string: trimmed)
        }
        return nil
    }
}

extension UUID: LenientDecodable {
    /// UUID 宽松转换：支持字符串 / UUID
    public static func lenientDecode(_ any: Any) -> UUID? {
        if let u = any as? UUID { return u }
        if let s = any as? String { return UUID(uuidString: s) }
        return nil
    }
}

extension Decimal: LenientDecodable {
    /// Decimal 宽松转换：支持 Decimal / Double / Int / String，优先从字符串解析以保精度
    public static func lenientDecode(_ any: Any) -> Decimal? {
        if let d = any as? Decimal { return d }
        if let s = any as? String { return Decimal(string: s) }
        if let d = any as? Double { return Decimal(d) }
        if let f = any as? Float { return Decimal(Double(f)) }
        if let i = any as? Int { return Decimal(i) }
        if let i = any as? Int64 { return Decimal(i) }
        if let b = any as? Bool { return Decimal(b ? 1 : 0) }
        return nil
    }
}

// MARK: - Optional

/// Optional 宽松转换
///
/// 让 `@CodingLenient var x: Int?` 这类写法自动工作：
/// - JSON `null` / `NSNull` → `.some(nil)`（解到 Optional 里的 nil）
/// - Wrapped 能宽松解出值 → `.some(.some(value))`
/// - 无法转换 → `.some(nil)`（兜底为 nil，而不是抛错）
extension Optional: LenientDecodable where Wrapped: LenientDecodable {
    public static func lenientDecode(_ any: Any) -> Optional<Wrapped>? {
        if any is NSNull { return .some(nil) }
        if let v = Wrapped.lenientDecode(any) {
            return .some(.some(v))
        }
        // 内层转换失败：也按 nil 处理（宽松语义）
        return .some(nil)
    }
}
