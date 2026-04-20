//
//  RGBAColorAdapter.swift
//  xxf_ios
//
//  字符串 ↔ RGBAColor 适配器
//
//  Created by xxf
//

import Foundation

/// 平台无关的 RGBA 颜色模型
/// 由于`UIColor` / `NSColor` 无法参与codable解析
/// 与 `UIColor` / `NSColor` 解耦：仅存储四个 `UInt8` 分量，便于持久化 / 跨模块传递。
/// 需要转为平台颜色时，可在业务层各自加扩展。
public struct RGBAColor: Codable, Equatable, Hashable {
    public let r: UInt8 // 0-255
    public let g: UInt8
    public let b: UInt8
    public let a: UInt8

    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}

/// RGBA 颜色适配器
///
/// 支持两种字符串格式与 `RGBAColor` 双向转换：
///
/// - `rgba(r,g,b,a)`：r/g/b ∈ [0, 255] 整数，a ∈ [0, 1] 小数（也兼容 [0, 255]）
///   允许空白、`rgb(r,g,b)` 省略 alpha（默认 255）
/// - `#RRGGBB` / `#RRGGBBAA`：6 位不带 alpha，8 位带 alpha（末两位是 alpha）
///   允许省略 `#`，允许大小写
///
/// 编码时输出 `#RRGGBBAA` 格式。
///
/// ## 使用
///
/// ```swift
/// struct Theme: Codable {
///     @CodingBy<RGBAColorAdapter> var primary: RGBAColor
///     @CodingBy<RGBAColorAdapter> var accent: RGBAColor   // 可传 "rgba(255,107,190,1)"
///     @CodingBy<RGBAColorAdapter> var bg: RGBAColor       // 可传 "#FF00FF6F"
/// }
/// ```
public struct RGBAColorAdapter: CodingAdapter {
    public typealias Value = RGBAColor

    public static func decode(from decoder: Decoder) throws -> RGBAColor {
        let c = try decoder.singleValueContainer()
        let raw = try c.decode(String.self)
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        if let color = _parseRGBA(s) { return color }
        if let color = _parseHex(s) { return color }

        throw DecodingError.dataCorruptedError(in: c,
                                               debugDescription: "RGBAColorAdapter failed to parse color string: \(raw)")
    }

    public static func encode(_ value: RGBAColor, to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(_hexString(value))
    }

    // MARK: - rgba(r,g,b,a)

    private static func _parseRGBA(_ s: String) -> RGBAColor? {
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
        return RGBAColor(r: r, g: g, b: b, a: a)
    }

    private static func _componentByte(_ s: String) -> UInt8? {
        guard let v = Double(s) else { return nil }
        return UInt8(min(max(v, 0), 255).rounded())
    }

    // MARK: - #RRGGBB / #RRGGBBAA

    private static func _parseHex(_ s: String) -> RGBAColor? {
        var hex = s
        if hex.hasPrefix("#") { hex.removeFirst() }
        hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        guard hex.count == 6 || hex.count == 8,
              hex.allSatisfy(\.isHexDigit),
              let value = UInt32(hex, radix: 16) else { return nil }

        if hex.count == 8 {
            return RGBAColor(
                r: UInt8((value >> 24) & 0xFF),
                g: UInt8((value >> 16) & 0xFF),
                b: UInt8((value >> 8) & 0xFF),
                a: UInt8(value & 0xFF)
            )
        } else {
            return RGBAColor(
                r: UInt8((value >> 16) & 0xFF),
                g: UInt8((value >> 8) & 0xFF),
                b: UInt8(value & 0xFF),
                a: 255
            )
        }
    }

    // MARK: - 编码：统一输出 #RRGGBBAA

    private static func _hexString(_ color: RGBAColor) -> String {
        String(format: "#%02X%02X%02X%02X", color.r, color.g, color.b, color.a)
    }
}
