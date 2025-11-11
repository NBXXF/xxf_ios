//

#if canImport(CoreGraphics)

    import CoreGraphics
    import Foundation

    public extension CGImage {
        /// The size of the CGImage
        @inlinable @inline(__always) var size: CGSize {
            CGSize(width: width, height: height)
        }
    }

#endif
