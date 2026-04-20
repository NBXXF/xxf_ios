//
//  Color+Hex.swift
//  xxf_ios
//
//  Created by xxf on 2022/7/11.
//

#if canImport(UIKit)
import UIKit

public typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit

public typealias PlatformColor = NSColor
#endif

#if canImport(UIKit) || canImport(AppKit)

public extension PlatformColor {

    /// 16 进制整型初始化（6 位 `0xRRGGBB`）
    ///
    /// ```swift
    /// UIColor(hex: 0xEF4444)
    /// UIColor(hex: 0x000000, alpha: 0.06)
    /// ```
    ///
    /// - Note: 仅取低 24 位；需要 8 位带 alpha 的形式请用字符串初始化器
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8) & 0xFF) / 255
        let b = CGFloat(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    /// 字符串 hex 初始化：`#RRGGBB` / `#RRGGBBAA`
    ///
    /// - 允许省略 `#`、允许大小写混合、允许前后空白
    /// - 8 位末两位为 alpha；6 位 alpha 默认 1.0
    /// - 非法输入返回 `nil`
    ///
    /// ```swift
    /// UIColor(hex: "#FF00FF")     // alpha = 1
    /// UIColor(hex: "#FF00FFFF")   // alpha = 1
    /// UIColor(hex: "FF00FF6F")    // alpha = 0x6F/0xFF
    /// ```
    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6 || s.count == 8,
              s.allSatisfy(\.isHexDigit),
              let value = UInt32(s, radix: 16) else { return nil }

        if s.count == 8 {
            let r = CGFloat((value >> 24) & 0xFF) / 255
            let g = CGFloat((value >> 16) & 0xFF) / 255
            let b = CGFloat((value >> 8) & 0xFF) / 255
            let a = CGFloat(value & 0xFF) / 255
            self.init(red: r, green: g, blue: b, alpha: a)
        } else {
            self.init(hex: Int(value))
        }
    }
}

#endif
