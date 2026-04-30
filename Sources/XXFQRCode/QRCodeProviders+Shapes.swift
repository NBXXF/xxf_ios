//
//  QRCodeProviders+Shapes.swift
//  XXFQRCode
//
//  对 dagronf/QRCode 的 EyeShape / PixelShape / PupilShape 的包装工厂。
//  目的：业务只需 `import XXFQRCode` 即可调用 `.roundedOuter()` / `.roundedPath(...)` 等，
//       无需再 `import QRCode`。
//

import CoreGraphics
import Foundation
import QRCode

// MARK: - EyeShape

public extension QRCodeProviders {
    /// 二维码三个定位角（eye）形状。
    struct EyeShape {
        let inner: any QRCodeEyeShapeGenerator

        // ── 无参 ────────────────────────────────────────────────

        public static func barsHorizontal() -> EyeShape { .init(inner: QRCode.EyeShape.BarsHorizontal()) }
        public static func barsVertical() -> EyeShape { .init(inner: QRCode.EyeShape.BarsVertical()) }
        public static func crt() -> EyeShape { .init(inner: QRCode.EyeShape.CRT()) }
        public static func circle() -> EyeShape { .init(inner: QRCode.EyeShape.Circle()) }
        public static func fireball() -> EyeShape { .init(inner: QRCode.EyeShape.Fireball()) }
        public static func leaf() -> EyeShape { .init(inner: QRCode.EyeShape.Leaf()) }
        public static func peacock() -> EyeShape { .init(inner: QRCode.EyeShape.Peacock()) }
        public static func pinch() -> EyeShape { .init(inner: QRCode.EyeShape.Pinch()) }
        public static func roundedOuter() -> EyeShape { .init(inner: QRCode.EyeShape.RoundedOuter()) }
        public static func roundedPointingIn() -> EyeShape { .init(inner: QRCode.EyeShape.RoundedPointingIn()) }
        public static func roundedPointingOut() -> EyeShape { .init(inner: QRCode.EyeShape.RoundedPointingOut()) }
        public static func roundedRect() -> EyeShape { .init(inner: QRCode.EyeShape.RoundedRect()) }
        public static func square() -> EyeShape { .init(inner: QRCode.EyeShape.Square()) }
        public static func squircle() -> EyeShape { .init(inner: QRCode.EyeShape.Squircle()) }
        public static func teardrop() -> EyeShape { .init(inner: QRCode.EyeShape.Teardrop()) }
        public static func usePixelShape() -> EyeShape { .init(inner: QRCode.EyeShape.UsePixelShape()) }

        // ── 带参 ────────────────────────────────────────────────

        public static func corneredPixels(cornerRadiusFraction: CGFloat = 0.65) -> EyeShape {
            .init(inner: QRCode.EyeShape.CorneredPixels(cornerRadiusFraction: cornerRadiusFraction))
        }

        public static func edges(cornerRadiusFraction: CGFloat = 0.65) -> EyeShape {
            .init(inner: QRCode.EyeShape.Edges(cornerRadiusFraction: cornerRadiusFraction))
        }

        public static func pixels(cornerRadiusFraction: CGFloat = 0.65) -> EyeShape {
            .init(inner: QRCode.EyeShape.Pixels(cornerRadiusFraction: cornerRadiusFraction))
        }

        /// 盾形，四个角分别指定是否圆角。
        public static func shield(
            topLeft: Bool = true,
            topRight: Bool = true,
            bottomLeft: Bool = false,
            bottomRight: Bool = false
        ) -> EyeShape {
            .init(inner: QRCode.EyeShape.Shield(
                topLeft: topLeft, topRight: topRight,
                bottomLeft: bottomLeft, bottomRight: bottomRight
            ))
        }

        public static func ufo(isFlipped: Bool = false) -> EyeShape {
            .init(inner: QRCode.EyeShape.UFO(isFlipped: isFlipped))
        }
    }
}

// MARK: - PupilShape

public extension QRCodeProviders {
    /// 二维码定位角内部瞳孔形状。
    struct PupilShape {
        let inner: any QRCodePupilShapeGenerator

        // ── 无参 ────────────────────────────────────────────────

        public static func barsHorizontal() -> PupilShape { .init(inner: QRCode.PupilShape.BarsHorizontal()) }
        public static func barsVertical() -> PupilShape { .init(inner: QRCode.PupilShape.BarsVertical()) }
        public static func blobby() -> PupilShape { .init(inner: QRCode.PupilShape.Blobby()) }
        public static func crt() -> PupilShape { .init(inner: QRCode.PupilShape.CRT()) }
        public static func circle() -> PupilShape { .init(inner: QRCode.PupilShape.Circle()) }
        public static func cross() -> PupilShape { .init(inner: QRCode.PupilShape.Cross()) }
        public static func crossCurved() -> PupilShape { .init(inner: QRCode.PupilShape.CrossCurved()) }
        public static func hexagonLeaf() -> PupilShape { .init(inner: QRCode.PupilShape.HexagonLeaf()) }
        public static func leaf() -> PupilShape { .init(inner: QRCode.PupilShape.Leaf()) }
        public static func pinch() -> PupilShape { .init(inner: QRCode.PupilShape.Pinch()) }
        public static func roundedOuter() -> PupilShape { .init(inner: QRCode.PupilShape.RoundedOuter()) }
        public static func roundedPointingIn() -> PupilShape { .init(inner: QRCode.PupilShape.RoundedPointingIn()) }
        public static func roundedPointingOut() -> PupilShape { .init(inner: QRCode.PupilShape.RoundedPointingOut()) }
        public static func roundedRect() -> PupilShape { .init(inner: QRCode.PupilShape.RoundedRect()) }
        public static func seal() -> PupilShape { .init(inner: QRCode.PupilShape.Seal()) }
        public static func square() -> PupilShape { .init(inner: QRCode.PupilShape.Square()) }
        public static func squircle() -> PupilShape { .init(inner: QRCode.PupilShape.Squircle()) }
        public static func teardrop() -> PupilShape { .init(inner: QRCode.PupilShape.Teardrop()) }
        public static func usePixelShape() -> PupilShape { .init(inner: QRCode.PupilShape.UsePixelShape()) }

        // ── 带参 ────────────────────────────────────────────────

        public static func corneredPixels(cornerRadiusFraction: CGFloat = 0.65) -> PupilShape {
            .init(inner: QRCode.PupilShape.CorneredPixels(cornerRadiusFraction: cornerRadiusFraction))
        }

        public static func edges(cornerRadiusFraction: CGFloat = 0.65) -> PupilShape {
            .init(inner: QRCode.PupilShape.Edges(cornerRadiusFraction: cornerRadiusFraction))
        }

        public static func pixels(cornerRadiusFraction: CGFloat = 0.65) -> PupilShape {
            .init(inner: QRCode.PupilShape.Pixels(cornerRadiusFraction: cornerRadiusFraction))
        }

        public static func shield(
            topLeft: Bool = true,
            topRight: Bool = true,
            bottomLeft: Bool = false,
            bottomRight: Bool = false
        ) -> PupilShape {
            .init(inner: QRCode.PupilShape.Shield(
                topLeft: topLeft, topRight: topRight,
                bottomLeft: bottomLeft, bottomRight: bottomRight
            ))
        }

        public static func ufo(isFlipped: Bool = false) -> PupilShape {
            .init(inner: QRCode.PupilShape.UFO(isFlipped: isFlipped))
        }
    }
}

// MARK: - PixelShape

public extension QRCodeProviders {
    /// 二维码数据点（onPixels）形状。
    struct PixelShape {
        let inner: any QRCodePixelShapeGenerator

        // ── 无参 ────────────────────────────────────────────────

        public static func blob() -> PixelShape { .init(inner: QRCode.PixelShape.Blob()) }
        public static func circuit() -> PixelShape { .init(inner: QRCode.PixelShape.Circuit()) }
        public static func pointy() -> PixelShape { .init(inner: QRCode.PixelShape.Pointy()) }
        public static func razor() -> PixelShape { .init(inner: QRCode.PixelShape.Razor()) }
        public static func shiny() -> PixelShape { .init(inner: QRCode.PixelShape.Shiny()) }

        // ── 带参 ────────────────────────────────────────────────

        public static func curvePixel(cornerRadiusFraction: CGFloat = 1) -> PixelShape {
            .init(inner: QRCode.PixelShape.CurvePixel(cornerRadiusFraction: cornerRadiusFraction))
        }

        public static func circle(insetFraction: CGFloat = 0, useRandomInset: Bool = false) -> PixelShape {
            .init(inner: QRCode.PixelShape.Circle(
                insetFraction: insetFraction,
                useRandomInset: useRandomInset
            ))
        }

        public static func crt(
            insetFraction: CGFloat = 0,
            useRandomInset: Bool = false,
            rotationFraction: CGFloat = 0,
            useRandomRotation: Bool = false
        ) -> PixelShape {
            .init(inner: QRCode.PixelShape.CRT(
                insetFraction: insetFraction,
                useRandomInset: useRandomInset,
                rotationFraction: rotationFraction,
                useRandomRotation: useRandomRotation
            ))
        }

        public static func flower(
            insetFraction: CGFloat = 0,
            useRandomInset: Bool = false,
            rotationFraction: CGFloat = 0,
            useRandomRotation: Bool = false
        ) -> PixelShape {
            .init(inner: QRCode.PixelShape.Flower(
                insetFraction: insetFraction,
                useRandomInset: useRandomInset,
                rotationFraction: rotationFraction,
                useRandomRotation: useRandomRotation
            ))
        }

        public static func horizontal(insetFraction: CGFloat = 0.05, cornerRadiusFraction: CGFloat = 1) -> PixelShape {
            .init(inner: QRCode.PixelShape.Horizontal(
                insetFraction: insetFraction,
                cornerRadiusFraction: cornerRadiusFraction
            ))
        }

        public static func vertical(insetFraction: CGFloat = 0.05, cornerRadiusFraction: CGFloat = 1) -> PixelShape {
            .init(inner: QRCode.PixelShape.Vertical(
                insetFraction: insetFraction,
                cornerRadiusFraction: cornerRadiusFraction
            ))
        }

        public static func roundedEndIndent(cornerRadiusFraction: CGFloat = 0.65, hasInnerCorners: Bool = false) -> PixelShape {
            .init(inner: QRCode.PixelShape.RoundedEndIndent(
                cornerRadiusFraction: cornerRadiusFraction,
                hasInnerCorners: hasInnerCorners
            ))
        }

        /// `cornerRadiusFraction: 0.7, hasInnerCorners: true` 即用户示例场景。
        public static func roundedPath(cornerRadiusFraction: CGFloat = 0.65, hasInnerCorners: Bool = false) -> PixelShape {
            .init(inner: QRCode.PixelShape.RoundedPath(
                cornerRadiusFraction: cornerRadiusFraction,
                hasInnerCorners: hasInnerCorners
            ))
        }

        public static func roundedRect(
            cornerRadiusFraction: CGFloat = 0.3,
            insetFraction: CGFloat = 0,
            useRandomInset: Bool = false,
            rotationFraction: CGFloat = 0,
            useRandomRotation: Bool = false
        ) -> PixelShape {
            .init(inner: QRCode.PixelShape.RoundedRect(
                cornerRadiusFraction: cornerRadiusFraction,
                insetFraction: insetFraction,
                useRandomInset: useRandomInset,
                rotationFraction: rotationFraction,
                useRandomRotation: useRandomRotation
            ))
        }

        public static func sharp(
            insetFraction: CGFloat = 0,
            useRandomInset: Bool = false,
            rotationFraction: CGFloat = 0,
            useRandomRotation: Bool = false
        ) -> PixelShape {
            .init(inner: QRCode.PixelShape.Sharp(
                insetFraction: insetFraction,
                useRandomInset: useRandomInset,
                rotationFraction: rotationFraction,
                useRandomRotation: useRandomRotation
            ))
        }

        public static func square(
            insetFraction: CGFloat = 0,
            useRandomInset: Bool = false,
            rotationFraction: CGFloat = 0,
            useRandomRotation: Bool = false
        ) -> PixelShape {
            .init(inner: QRCode.PixelShape.Square(
                insetFraction: insetFraction,
                useRandomInset: useRandomInset,
                rotationFraction: rotationFraction,
                useRandomRotation: useRandomRotation
            ))
        }

        public static func squircle(
            insetFraction: CGFloat = 0,
            useRandomInset: Bool = false,
            rotationFraction: CGFloat = 0,
            useRandomRotation: Bool = false
        ) -> PixelShape {
            .init(inner: QRCode.PixelShape.Squircle(
                insetFraction: insetFraction,
                useRandomInset: useRandomInset,
                rotationFraction: rotationFraction,
                useRandomRotation: useRandomRotation
            ))
        }

        public static func star(
            insetFraction: CGFloat = 0,
            useRandomInset: Bool = false,
            rotationFraction: CGFloat = 0,
            useRandomRotation: Bool = false
        ) -> PixelShape {
            .init(inner: QRCode.PixelShape.Star(
                insetFraction: insetFraction,
                useRandomInset: useRandomInset,
                rotationFraction: rotationFraction,
                useRandomRotation: useRandomRotation
            ))
        }
    }
}
