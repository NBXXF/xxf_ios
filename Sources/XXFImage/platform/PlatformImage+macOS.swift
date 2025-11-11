//

#if os(macOS)

    import AppKit
    import Foundation

    public extension NSImage {
        /// A trival CGImage representation for an NSImage
        @inlinable @inline(__always) var cgImage: CGImage? {
            if let image = self.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                return image
            }
            return ciImage?.asCGImage()
        }

        /// Return a CIImage for an NSImage
        @inlinable @inline(__always) var ciImage: CIImage? {
            tiffRepresentation(using: .none, factor: 0).flatMap(CIImage.init)
        }
    }

#endif
