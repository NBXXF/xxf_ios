//

#if canImport(CoreGraphics)

    import Foundation

    #if os(macOS)
        import AppKit

        public extension CGImage {
            /// Return a platform image with a specific scale (eg. 2 == @2x)
            func platformImage(scale: CGFloat = 1) -> PlatformImage {
                let sz = CGSize(width: width, height: height)
                let scaled = CGSize(width: sz.width / scale, height: sz.height / scale)
                return PlatformImage(cgImage: self, size: scaled)
            }
        }

        public extension CGImage.ImageRepresentation {
            /// Return an NSImage with a specific DPI
            /// - Parameter dpi: The DPI for the resulting image
            /// - Returns: An image
            @inlinable func nsImage(dpi: CGFloat) -> PlatformImage {
                image(dpi: dpi)
            }

            /// Return an NSImage with a specific scale (eg. 2 == @2x)
            /// - Parameter scale: The image scale
            /// - Returns: An image
            @inlinable func nsImage(scale: CGFloat = 1) -> PlatformImage {
                image(scale: scale)
            }
        }

    #else
        import UIKit

        public extension CGImage {
            /// Return a platform image with a specific scale (eg. 2 == @2x)
            func platformImage(scale: CGFloat = 1) -> PlatformImage {
                UIImage(cgImage: self, scale: scale, orientation: .up)
            }
        }

        public extension CGImage.ImageRepresentation {
            /// Return a UIImage with a specific DPI
            /// - Parameter dpi: The DPI for the resulting image
            /// - Returns: An image
            @inlinable func uiImage(dpi: CGFloat) -> PlatformImage {
                image(dpi: dpi)
            }

            /// Return a UIImage with a specific scale (eg. 2 == @2x)
            /// - Parameter scale: The image scale
            /// - Returns: An image
            @inlinable func uiImage(scale: CGFloat = 1) -> PlatformImage {
                image(scale: scale)
            }
        }
    #endif

    public extension CGImage {
        /// Return a platform image with a specific DPI
        func platformImage(dpi: CGFloat = 72.0) -> PlatformImage {
            platformImage(scale: dpi / 72.0)
        }
    }

#endif
