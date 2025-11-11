//

#if canImport(CoreGraphics)

    import CoreGraphics.CGImage
    import Foundation

    /// A codable wrapper for CGImage
    public struct CGImageCodable: Codable {
        /// The image
        public var image: CGImage

        /// Create a codable image with the provided image
        public init(_ image: CGImage) { self.image = image }
    }

    public extension CGImageCodable {
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            guard let imageData = try? container.decode(Data.self) else {
                throw ImageReadWriteError.codableInvalidData
            }
            guard let image = PlatformImage(data: imageData)?.cgImage else {
                throw ImageReadWriteError.codableInvalidImage
            }
            self.image = image
        }

        func encode(to encoder: Encoder) throws {
            let pngData = try image.imageData(for: .png())
            var container = encoder.singleValueContainer()
            try container.encode(pngData)
        }
    }

#endif
