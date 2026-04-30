//
//  QRCodeProviders+FillStyle.swift
//  XXFQRCode
//
//  对 dagronf/QRCode 的 FillStyle 及 Gradient 的包装工厂。
//  业务无需 `import QRCode` 即可构造 `.solid(...)` / `.linearGradient(...)` 等填充。
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

import CoreGraphics
import Foundation
import QRCode

// MARK: - FillStyle

public extension QRCodeProviders {
    /// 填充样式。用于 onPixels / background / eye / pupil。
    struct FillStyle {
        let inner: any QRCodeFillStyleGenerator

        // ── Solid ────────────────────────────────────────────────

        public static func solid(_ color: CGColor) -> FillStyle {
            .init(inner: QRCode.FillStyle.Solid(color))
        }

        /// 注意：传入 dynamic UIColor（如 `.label`）时，会在当前 trait 下解析一次，
        /// 之后不会随 Dark/Light mode 变化。如需主题响应请在调用点显式解析。
        public static func solid(_ color: XXFQRCodeColor) -> FillStyle {
            .init(inner: QRCode.FillStyle.Solid(color.cgColor))
        }

        public static func solid(srgbRed r: CGFloat, green g: CGFloat, blue b: CGFloat, alpha: CGFloat = 1) -> FillStyle {
            .init(inner: QRCode.FillStyle.Solid(srgbRed: r, green: g, blue: b, alpha: alpha))
        }

        public static func solid(gray: CGFloat, alpha: CGFloat = 1) -> FillStyle {
            .init(inner: QRCode.FillStyle.Solid(gray: gray, alpha: alpha))
        }

        // ── Gradient ────────────────────────────────────────────

        /// 线性渐变。`startPoint` / `endPoint` 为归一化 0..1 坐标（左上为原点）。
        public static func linearGradient(
            _ gradient: Gradient,
            startPoint: CGPoint = CGPoint(x: 0, y: 0),
            endPoint: CGPoint = CGPoint(x: 1, y: 1)
        ) -> FillStyle {
            .init(inner: QRCode.FillStyle.LinearGradient(
                gradient.inner,
                startPoint: startPoint,
                endPoint: endPoint
            ))
        }

        /// 径向渐变。`centerPoint` 为归一化 0..1 坐标。
        public static func radialGradient(
            _ gradient: Gradient,
            centerPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
        ) -> FillStyle {
            .init(inner: QRCode.FillStyle.RadialGradient(
                gradient.inner,
                centerPoint: centerPoint
            ))
        }

        // ── Image ────────────────────────────────────────────────

        public static func image(_ image: CGImage?) -> FillStyle {
            .init(inner: QRCode.FillStyle.Image(image))
        }

        public static func image(_ image: XXFQRCodeImage?) -> FillStyle {
            .init(inner: QRCode.FillStyle.Image(image: image))
        }
    }
}

// MARK: - Gradient

public extension QRCodeProviders {
    /// 渐变色定义，传入有序的色点（颜色 + 位置 0..1）。
    struct Gradient {
        let inner: DSFGradient

        /// 若色点非法（例如空数组）会返回 nil。
        public static func make(stops: [(color: CGColor, location: CGFloat)]) -> Gradient? {
            let pins = stops.map { DSFGradient.Pin($0.color, $0.location) }
            guard let g = try? DSFGradient(pins: pins) else { return nil }
            return Gradient(inner: g)
        }

        public static func make(stops: [(color: XXFQRCodeColor, location: CGFloat)]) -> Gradient? {
            make(stops: stops.map { ($0.color.cgColor, $0.location) })
        }
    }
}
