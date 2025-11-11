//

#if canImport(CoreImage)

    import CoreGraphics
    import CoreImage
    import Foundation

    public extension CIImage {
        /// Convert this image to a CGImage
        @inlinable func asCGImage(context: CIContext? = nil) -> CGImage? {
            let ctx = context ?? CIContext(options: nil)
            return ctx.createCGImage(self, from: extent)
        }
    }

    #if os(macOS)
        import AppKit

        public extension CIImage {
            /// Create an NSImage representation of this image
            /// - Parameters:
            ///   - pixelSize: The number of pixels in the result image. For a retina image (for example), pixelSize is double repSize
            ///   - repSize: The number of points in the result image
            /// - Returns: Converted image, or nil
            func asNSImage(pixelsSize: CGSize? = nil, repSize: CGSize? = nil) -> NSImage? {
                let rep = NSCIImageRep(ciImage: self)
                if let ps = pixelsSize {
                    rep.pixelsWide = Int(ps.width)
                    rep.pixelsHigh = Int(ps.height)
                }
                if let rs = repSize {
                    rep.size = rs
                }
                let updateImage = NSImage(size: rep.size)
                updateImage.addRepresentation(rep)
                return updateImage
            }

            /// Create an NSImage representation of this image
            @inlinable func asPlatformImage() -> PlatformImage? { asNSImage() }
        }

    #else

        import UIKit

        public extension CIImage {
            /// Create a UIImage representation of this image
            @inlinable func asUIImage() -> UIImage? { UIImage(ciImage: self) }
            /// Create a UIImage representation of this image
            @inlinable func asPlatformImage() -> PlatformImage? { asUIImage() }
        }

    #endif
#endif
