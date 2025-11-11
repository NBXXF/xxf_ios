//

/// Routines for converting image colorspaces
///
/// ```swift
/// let cmykImage = try image.convertColorspace.genericCMYK()
/// let grayImage = try image.convertColorspace.deviceGray()
/// let sRGBImage = try image.convertColorspace.sRGB()
/// ```

#if canImport(CoreGraphics)

    import CoreGraphics
    import Foundation

    // Default colorspaces
    private let csRGB = CGColorSpace(name: CGColorSpace.sRGB)!
    private let csCMYK = CGColorSpace(name: CGColorSpace.genericCMYK)!
    private let csGray = CGColorSpace(name: CGColorSpace.genericGrayGamma2_2)!

    public extension CGImage {
        /// Access methods for converting the colorspace
        var convertColorspace: ConvertColorspace { ConvertColorspace(image: self) }

        /// Colorspace converter container
        struct ConvertColorspace {
            private var image: CGImage
            fileprivate init(image: CGImage) {
                self.image = image
            }
        }
    }

    public extension CGImage.ConvertColorspace {
        /// Generate a representation of this image using the Generic CMYK colorspace
        /// - Returns: A new CMYK image
        ///
        /// Note: Generic CMYK colorspace does NOT support an alpha channel and will be
        /// stripped on convert
        func genericCMYK() throws -> CGImage {
            let w = Int(image.width)
            let h = Int(image.height)

            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
            guard
                let space = CGColorSpace(name: CGColorSpace.genericCMYK),
                let ctx = CGContext(
                    data: nil,
                    width: w,
                    height: h,
                    bitsPerComponent: 8,
                    bytesPerRow: w * 4,
                    space: space,
                    bitmapInfo: bitmapInfo.rawValue
                )
            else {
                throw ImageReadWriteError.cannotConvertColorspace
            }

            ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h), byTiling: false)
            guard let image = ctx.makeImage() else {
                throw ImageReadWriteError.internalError
            }

            return image
        }

        /// Generate a representation of this image using the `genericGrayGamma2_2` colorspace
        /// - Returns: A new image
        ///
        /// Note: Gray colorspace does NOT support an alpha channel and will be stripped on convert
        func gray() throws -> CGImage {
            let w = Int(image.width)
            let h = Int(image.height)

            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
            guard
                let ctx = CGContext(
                    data: nil,
                    width: w,
                    height: h,
                    bitsPerComponent: 8,
                    bytesPerRow: 0,
                    space: csGray,
                    bitmapInfo: bitmapInfo.rawValue
                )
            else {
                throw ImageReadWriteError.cannotConvertColorspace
            }

            ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h), byTiling: false)
            guard let image = ctx.makeImage() else {
                throw ImageReadWriteError.internalError
            }

            return image
        }

        /// Generate a representation of this image using the standard RGB colorspace
        /// - Returns: A new image
        func sRGB() throws -> CGImage {
            let w = Int(image.width)
            let h = Int(image.height)

            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
            guard
                let ctx = CGContext(
                    data: nil,
                    width: w,
                    height: h,
                    bitsPerComponent: 8,
                    bytesPerRow: w * 4,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: bitmapInfo.rawValue
                )
            else {
                throw ImageReadWriteError.cannotConvertColorspace
            }

            ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h), byTiling: false)
            guard let image = ctx.makeImage() else {
                throw ImageReadWriteError.internalError
            }

            return image
        }
    }

#endif
