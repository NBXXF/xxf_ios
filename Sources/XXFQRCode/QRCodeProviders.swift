//
//  QRCodeProviders.swift
//  XXFQRCode
//
//  二维码生成 Builder（底层实现使用 dagronf/QRCode）。
//
//  设计要点：
//  - 基础字段：content / outputSize / contentColor / contentFillImage /
//    contentPadding / backgroundColor / logo / logoPercent / errorCorrection。
//  - 样式扩展暴露 dagronf/QRCode 原生能力（eye / pupil / onPixels 的 shape & FillStyle），
//    可覆盖用户给出的"圆角眼 + 圆角数据点 + 自定义前景/背景"场景。
//  - build() 返回 UIImage（iOS）/ NSImage（macOS）；scale 默认取屏幕 scale，得到 Retina 高清图。
//
//  Created by xxf on 2026/04/30.
//

#if canImport(UIKit)
import UIKit
public typealias XXFQRCodeImage = UIImage
public typealias XXFQRCodeColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias XXFQRCodeImage = NSImage
public typealias XXFQRCodeColor = NSColor
#endif

import CoreGraphics
import Foundation
import QRCode

// MARK: - 容错率

/// 二维码容错率，对应 ZXing `ErrorCorrectionLevel` 的 L/M/Q/H。
///
/// | case      | 恢复率 | ZXing | 说明          |
/// |-----------|-------|-------|--------------|
/// | .low      | ~7%   | L     | 最大容量      |
/// | .medium   | ~15%  | M     | 默认          |
/// | .quantize | ~25%  | Q     |              |
/// | .high     | ~30%  | H     | 推荐带 logo   |
public enum XXFQRCodeErrorCorrection {
    case low, medium, quantize, high

    fileprivate var inner: QRCode.ErrorCorrection {
        switch self {
        case .low: return .low
        case .medium: return .medium
        case .quantize: return .quantize
        case .high: return .high
        }
    }
}

// MARK: - Providers

/// 二维码生成入口。
///
/// 基础用法：
/// ```swift
/// let img = QRCodeProviders.of("https://example.com").build()
/// ```
///
/// 样式用法（等价于用户给出的 `generateQRCode(from:pixelSize:)` 场景）：
/// ```swift
/// let img = QRCodeProviders.of("https://example.com")
///     .errorCorrection(.high)
///     .outputSize(CGSize(width: pixelSize, height: pixelSize))
///     .eyeShape(.roundedOuter())
///     .pixelShape(.roundedPath(cornerRadiusFraction: 0.7, hasInnerCorners: true))
///     .onPixelsStyle(.solid(UIColor.black))
///     .backgroundStyle(.solid(UIColor.white))
///     .build()
/// ```
public enum QRCodeProviders {
    /// 创建 Builder 入口。
    public static func of(_ content: String) -> Builder {
        return Builder(content: content)
    }

    /// 二维码构建器（链式调用）。
    public final class Builder {
        // MARK: - 基础字段

        /// 二维码内容。
        public let content: String
        /// 文本编码（默认 UTF-8）；非 UTF-8 时会以对应编码的字节流编码到二维码中。
        public private(set) var charset: String.Encoding = .utf8
        /// 输出尺寸（points）。默认 200×200。
        public private(set) var outputSize: CGSize = CGSize(width: 200, height: 200)
        /// 渲染缩放，默认取屏幕 scale；设为 1 得到 1x 图。
        public private(set) var scale: CGFloat = Builder.defaultScale
        /// 数据点颜色（未设置 `onPixelsStyle` / `contentFillImage` 时生效）。
        public private(set) var contentColor: XXFQRCodeColor = .black
        /// 数据点图片填充；设置后覆盖 `contentColor`。
        public private(set) var contentFillImage: XXFQRCodeImage?
        /// 内边距（quiet zone 像素数）。默认 1。
        public private(set) var contentPadding: Int = 1
        /// 背景色（未设置 `backgroundStyle` 时生效）。
        public private(set) var backgroundColor: XXFQRCodeColor = .white
        /// 中心 logo（图片）。
        public private(set) var logo: XXFQRCodeImage?
        /// logo 占整张二维码宽的百分比，默认 0.2。
        public private(set) var logoPercent: CGFloat = 0.2
        /// 容错率，默认 `.medium`（对应 M）。
        public private(set) var errorCorrection: XXFQRCodeErrorCorrection = .medium

        // MARK: - 样式扩展（可选）

        /// 眼形（三个定位角）。见 `QRCodeProviders.EyeShape` 的工厂。
        public private(set) var eyeShape: EyeShape?
        /// 瞳孔形状。见 `QRCodeProviders.PupilShape` 的工厂。
        public private(set) var pupilShape: PupilShape?
        /// 数据点形状（`onPixels`）。见 `QRCodeProviders.PixelShape` 的工厂。
        public private(set) var pixelShape: PixelShape?
        /// 数据点填充（优先级高于 `contentColor` / `contentFillImage`）。
        public private(set) var onPixelsStyle: FillStyle?
        /// 背景填充（优先级高于 `backgroundColor`）。
        public private(set) var backgroundStyle: FillStyle?
        /// 眼形填充。
        public private(set) var eyeStyle: FillStyle?
        /// 瞳孔填充。
        public private(set) var pupilStyle: FillStyle?

        init(content: String) {
            self.content = content
        }

        private static var defaultScale: CGFloat {
            #if canImport(UIKit) && !os(watchOS)
            return UIScreen.main.scale
            #else
            return 1
            #endif
        }

        // MARK: - 基础 setter（链式）

        @discardableResult public func charset(_ v: String.Encoding) -> Builder { charset = v; return self }
        @discardableResult public func outputSize(_ v: CGSize) -> Builder { outputSize = v; return self }
        @discardableResult public func scale(_ v: CGFloat) -> Builder { scale = v; return self }
        @discardableResult public func contentColor(_ v: XXFQRCodeColor) -> Builder { contentColor = v; return self }
        @discardableResult public func contentFillImage(_ v: XXFQRCodeImage?) -> Builder { contentFillImage = v; return self }
        @discardableResult public func contentPadding(_ v: Int) -> Builder { contentPadding = v; return self }
        @discardableResult public func backgroundColor(_ v: XXFQRCodeColor) -> Builder { backgroundColor = v; return self }
        @discardableResult public func logo(_ v: XXFQRCodeImage?) -> Builder { logo = v; return self }
        @discardableResult public func logoPercent(_ v: CGFloat) -> Builder { logoPercent = v; return self }
        @discardableResult public func errorCorrection(_ v: XXFQRCodeErrorCorrection) -> Builder { errorCorrection = v; return self }

        // MARK: - 样式 setter（链式）

        @discardableResult public func eyeShape(_ v: EyeShape?) -> Builder { eyeShape = v; return self }
        @discardableResult public func pupilShape(_ v: PupilShape?) -> Builder { pupilShape = v; return self }
        @discardableResult public func pixelShape(_ v: PixelShape?) -> Builder { pixelShape = v; return self }
        @discardableResult public func onPixelsStyle(_ v: FillStyle?) -> Builder { onPixelsStyle = v; return self }
        @discardableResult public func backgroundStyle(_ v: FillStyle?) -> Builder { backgroundStyle = v; return self }
        @discardableResult public func eyeStyle(_ v: FillStyle?) -> Builder { eyeStyle = v; return self }
        @discardableResult public func pupilStyle(_ v: FillStyle?) -> Builder { pupilStyle = v; return self }

        // MARK: - 构建

        /// 生成 `CGImage`（像素尺寸 = outputSize × scale）。
        public func buildCGImage() -> CGImage? {
            do {
                let doc = try QRCode.Document(utf8String: content, errorCorrection: errorCorrection.inner)

                // 非 UTF-8 时按指定编码覆写字节流
                if charset != .utf8, let data = content.data(using: charset) {
                    doc.data = data
                }

                // 内边距（contentPadding → dagronf additionalQuietZonePixels）
                doc.design.additionalQuietZonePixels = UInt(max(0, contentPadding))

                // 形状
                if let eye = eyeShape { doc.design.shape.eye = eye.inner }
                if let pupil = pupilShape { doc.design.shape.pupil = pupil.inner }
                if let pixel = pixelShape { doc.design.shape.onPixels = pixel.inner }

                // 数据点填充：onPixelsStyle > contentFillImage > contentColor
                if let style = onPixelsStyle {
                    doc.design.style.onPixels = style.inner
                } else if let img = contentFillImage, let cg = img.xxf_cgImage {
                    doc.design.style.onPixels = QRCode.FillStyle.Image(cg)
                } else {
                    doc.design.style.onPixels = QRCode.FillStyle.Solid(contentColor.cgColor)
                }

                // 背景填充：backgroundStyle > backgroundColor
                if let style = backgroundStyle {
                    doc.design.style.background = style.inner
                } else {
                    doc.design.style.background = QRCode.FillStyle.Solid(backgroundColor.cgColor)
                }

                if let eyeStyle { doc.design.style.eye = eyeStyle.inner }
                if let pupilStyle { doc.design.style.pupil = pupilStyle.inner }

                // Logo：居中矩形，尺寸为 logoPercent×logoPercent（归一化 0..1 坐标）
                if let logo, let cg = logo.xxf_cgImage, logoPercent > 0 {
                    let size = max(0, min(1, logoPercent))
                    let origin = (1 - size) / 2
                    let path = CGPath(
                        rect: CGRect(x: origin, y: origin, width: size, height: size),
                        transform: nil
                    )
                    doc.logoTemplate = QRCode.LogoTemplate(image: cg, path: path, inset: 2)
                }

                let pixelW = Int(ceil(outputSize.width * scale))
                let pixelH = Int(ceil(outputSize.height * scale))
                return try doc.cgImage(CGSize(width: pixelW, height: pixelH))
            } catch {
                return nil
            }
        }

        /// 生成平台图片（iOS `UIImage` / macOS `NSImage`）。
        public func build() -> XXFQRCodeImage? {
            guard let cg = buildCGImage() else { return nil }
            #if canImport(UIKit)
            return UIImage(cgImage: cg, scale: scale, orientation: .up)
            #elseif canImport(AppKit)
            return NSImage(cgImage: cg, size: outputSize)
            #endif
        }
    }
}

// MARK: - 平台图片 → CGImage

private extension XXFQRCodeImage {
    var xxf_cgImage: CGImage? {
        #if canImport(UIKit)
        return self.cgImage
        #elseif canImport(AppKit)
        var rect = CGRect(origin: .zero, size: self.size)
        return self.cgImage(forProposedRect: &rect, context: nil, hints: nil)
        #endif
    }
}
