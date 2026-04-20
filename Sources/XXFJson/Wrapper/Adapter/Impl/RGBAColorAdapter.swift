//
//  RGBAColorAdapter.swift
//  xxf_ios
//
//  字符串 ↔ UIColor / NSColor 适配器
//
//  Created by xxf
//

import Foundation

#if canImport(UIKit)
import UIKit
public typealias _RGBAPlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias _RGBAPlatformColor = NSColor
#endif

#if canImport(UIKit) || canImport(AppKit)

/// RGBA 颜色适配器
///
/// 支持两种字符串格式与 `UIColor` / `NSColor` 双向转换：
///
/// - `rgba(r,g,b,a)`：r/g/b ∈ [0, 255] 整数，a ∈ [0, 1] 小数（也兼容 [0, 255]）
///   允许空白、`rgb(r,g,b)` 省略 alpha（默认 1.0）
/// - `#RRGGBB` / `#RRGGBBAA`：6 位不带 alpha，8 位带 alpha（末两位是 alpha）
///   允许省略 `#`，允许大小写
///
/// 编码时输出 `#RRGGBBAA` 格式。
///
/// ## 使用
///
/// ```swift
/// struct Theme: Codable {
///     @CodingBy<RGBAColorAdapter> var primary: UIColor
///     @CodingBy<RGBAColorAdapter> var accent: UIColor   // 可传 "rgba(255,107,190,1)"
///     @CodingBy<RGBAColorAdapter> var bg: UIColor       // 可传 "#FF00FF6F"
/// }
/// ```
public struct RGBAColorAdapter: CodingAdapter {

    public typealias Value = _RGBAPlatformColor

    public static func decode(from decoder: Decoder) throws -> _RGBAPlatformColor {
        let c = try decoder.singleValueContainer()
        let raw = try c.decode(String.self)
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        if let color = _parseRGBA(s) { return color }
        if let color = _parseHex(s) { return color }

        throw DecodingError.dataCorruptedError(in: c,
            debugDescription: "RGBAColorAdapter failed to parse color string: \(raw)")
    }

    public static func encode(_ value: _RGBAPlatformColor, to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(_hexString(value))
    }

    // MARK: - rgba(r,g,b,a)

    private static func _parseRGBA(_ s: String) -> _RGBAPlatformColor? {
        let lower = s.lowercased()
        // 必须紧跟 "("，避免 "rgbaa(...)" 之类误匹配
        guard lower.hasPrefix("rgba(") || lower.hasPrefix("rgb(") else { return nil }
        guard let lp = s.firstIndex(of: "("), let rp = s.lastIndex(of: ")"), lp < rp else { return nil }

        let body = s[s.index(after: lp) ..< rp]
        let parts = body.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 3 || parts.count == 4 else { return nil }

        guard let r = _component255(parts[0]),
              let g = _component255(parts[1]),
              let b = _component255(parts[2]) else { return nil }

        var a: CGFloat = 1
        if parts.count == 4 {
            guard let av = Double(parts[3]) else { return nil }
            // 兼容 a 写成 0~255
            a = av > 1 ? CGFloat(av) / 255 : CGFloat(av)
        }
        return _RGBAPlatformColor(red: r, green: g, blue: b, alpha: min(max(a, 0), 1))
    }

    private static func _component255(_ s: String) -> CGFloat? {
        guard let v = Double(s) else { return nil }
        return CGFloat(min(max(v, 0), 255)) / 255
    }

    // MARK: - #RRGGBB / #RRGGBBAA

    private static func _parseHex(_ s: String) -> _RGBAPlatformColor? {
        var hex = s
        if hex.hasPrefix("#") { hex.removeFirst() }
        hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        guard hex.count == 6 || hex.count == 8,
              hex.allSatisfy(\.isHexDigit),
              let value = UInt32(hex, radix: 16) else { return nil }

        let r, g, b, a: CGFloat
        if hex.count == 8 {
            r = CGFloat((value >> 24) & 0xFF) / 255
            g = CGFloat((value >> 16) & 0xFF) / 255
            b = CGFloat((value >> 8) & 0xFF) / 255
            a = CGFloat(value & 0xFF) / 255
        } else {
            r = CGFloat((value >> 16) & 0xFF) / 255
            g = CGFloat((value >> 8) & 0xFF) / 255
            b = CGFloat(value & 0xFF) / 255
            a = 1
        }
        return _RGBAPlatformColor(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - 编码：统一输出 #RRGGBBAA

    private static func _hexString(_ color: _RGBAPlatformColor) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        #if canImport(UIKit)
        // pattern image / 不兼容色空间时 getRed 返回 false，回退到 cgColor.components
        if !color.getRed(&r, green: &g, blue: &b, alpha: &a) {
            _fallbackFromCGColor(color.cgColor, r: &r, g: &g, b: &b, a: &a)
        }
        #else
        // NSColor 非 RGB 色空间直接调 getRed 会抛 Objective-C 异常
        if let rgb = color.usingColorSpace(.sRGB) ?? color.usingColorSpace(.deviceRGB) {
            rgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        } else {
            _fallbackFromCGColor(color.cgColor, r: &r, g: &g, b: &b, a: &a)
        }
        #endif

        func byte(_ f: CGFloat) -> Int { Int((min(max(f, 0), 1) * 255).rounded()) }
        return String(format: "#%02X%02X%02X%02X", byte(r), byte(g), byte(b), byte(a))
    }

    private static func _fallbackFromCGColor(
        _ cg: CGColor,
        r: inout CGFloat, g: inout CGFloat, b: inout CGFloat, a: inout CGFloat
    ) {
        guard let comps = cg.components, !comps.isEmpty else { return }
        switch comps.count {
        case 2:  // grayscale + alpha
            r = comps[0]; g = comps[0]; b = comps[0]; a = comps[1]
        case 3:
            r = comps[0]; g = comps[1]; b = comps[2]; a = 1
        case 4...:
            r = comps[0]; g = comps[1]; b = comps[2]; a = comps[3]
        default:
            break
        }
    }
}

#endif
