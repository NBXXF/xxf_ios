//
//  ColorHexStringAdapter.swift
//  xxf_ios
//
//  颜色字符串归一化适配器：rgba(...) / 6 位 hex → #RRGGBBAA
//
//  Created by xxf
//

import Foundation

/// 颜色字符串归一化适配器
///
/// 把后端可能传来的两种颜色写法统一解码为 `#RRGGBBAA` 形式的 `String`：
///
/// - `rgba(r,g,b,a)` / `rgb(r,g,b)`：r/g/b ∈ [0, 255]；a ∈ [0, 1] 小数或 [0, 255] 整数
/// - `#RRGGBB` / `#RRGGBBAA`：省略 `#` / 大小写混合均接受；6 位会补 alpha = `FF`
///
/// 解码结果始终大写、带 `#`、8 位长度。无法解析的字符串直接抛 `dataCorrupted`。
/// 编码时原样写出当前字符串（上层已是归一化格式）。
///
/// ## 使用
///
/// ```swift
/// struct Theme: Codable {
///     @CodingBy<ColorHexStringAdapter> var primary: String   // "#RRGGBBAA"
///     @CodingBy<ColorHexStringAdapter> var accent: String    // 可传 "rgba(255,107,190,1)"
///     @CodingBy<ColorHexStringAdapter> var bg: String        // 可传 "#FF00FF6F"
/// }
/// ```
public struct ColorHexStringAdapter: CodingAdapter {
    public typealias Value = String

    public static func decode(from decoder: Decoder) throws -> String {
        let c = try decoder.singleValueContainer()
        let raw = try c.decode(String.self)
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        if let hex = _normalizeRGBA(s) { return hex }
        if let hex = _normalizeHex(s) { return hex }

        throw DecodingError.dataCorruptedError(in: c,
                                               debugDescription: "ColorHexStringAdapter failed to parse color string: \(raw)")
    }

    public static func encode(_ value: String, to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(value)
    }

    // MARK: - rgba(r,g,b,a) → #RRGGBBAA

    private static func _normalizeRGBA(_ s: String) -> String? {
        let lower = s.lowercased()
        // 必须紧跟 "("，避免 "rgbaa(...)" 之类误匹配
        guard lower.hasPrefix("rgba(") || lower.hasPrefix("rgb(") else { return nil }
        guard let lp = s.firstIndex(of: "("), let rp = s.lastIndex(of: ")"), lp < rp else { return nil }

        let body = s[s.index(after: lp) ..< rp]
        let parts = body.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 3 || parts.count == 4 else { return nil }

        guard let r = _componentByte(parts[0]),
              let g = _componentByte(parts[1]),
              let b = _componentByte(parts[2]) else { return nil }

        var a: UInt8 = 255
        if parts.count == 4 {
            guard let av = Double(parts[3]) else { return nil }
            // 兼容 a 写成 0~1 小数 或 0~255 整数
            if av > 1 {
                a = UInt8(min(max(av, 0), 255).rounded())
            } else {
                a = UInt8((min(max(av, 0), 1) * 255).rounded())
            }
        }
        return _hexString(r: r, g: g, b: b, a: a)
    }

    private static func _componentByte(_ s: String) -> UInt8? {
        guard let v = Double(s) else { return nil }
        return UInt8(min(max(v, 0), 255).rounded())
    }

    // MARK: - #RRGGBB / #RRGGBBAA → #RRGGBBAA

    private static func _normalizeHex(_ s: String) -> String? {
        var hex = s
        if hex.hasPrefix("#") { hex.removeFirst() }
        hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        guard hex.count == 6 || hex.count == 8,
              hex.allSatisfy(\.isHexDigit),
              let value = UInt32(hex, radix: 16) else { return nil }

        let r, g, b, a: UInt8
        if hex.count == 8 {
            r = UInt8((value >> 24) & 0xFF)
            g = UInt8((value >> 16) & 0xFF)
            b = UInt8((value >> 8) & 0xFF)
            a = UInt8(value & 0xFF)
        } else {
            r = UInt8((value >> 16) & 0xFF)
            g = UInt8((value >> 8) & 0xFF)
            b = UInt8(value & 0xFF)
            a = 255
        }
        return _hexString(r: r, g: g, b: b, a: a)
    }

    // MARK: - 统一输出 #RRGGBBAA

    private static func _hexString(r: UInt8, g: UInt8, b: UInt8, a: UInt8) -> String {
        String(format: "#%02X%02X%02X%02X", r, g, b, a)
    }
}
