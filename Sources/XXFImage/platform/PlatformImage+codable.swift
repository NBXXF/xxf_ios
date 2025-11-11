//

#if canImport(CoreGraphics)

    import Foundation

    #if os(macOS)
        import AppKit
    #else
        import UIKit
    #endif

    /// A codable wrapper for NSImage/UIImage
    @available(macOS 10.13, iOS 11, tvOS 13, watchOS 6, *)
    public struct PlatformImageCodable: Codable {
        /// The image to encode
        public var image: PlatformImage

        /// Create with a specific image
        public init(_ image: PlatformImage) {
            self.image = image
        }
    }

    @available(macOS 10.13, iOS 11, tvOS 13, watchOS 6, *)
    public extension PlatformImageCodable {
        /// The types of error that the codable image can throw
        enum ImageCodingError: Error {
            case InvalidData
            case UnableToConvertImageToPNG
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            guard let imageData = try? container.decode(Data.self) else {
                throw ImageCodingError.InvalidData
            }

            guard let image = try NSKeyedUnarchiver.unarchivedObject(ofClass: PlatformImage.self, from: imageData) else {
                throw ImageCodingError.InvalidData
            }

            self.image = image
        }

        func encode(to encoder: Encoder) throws {
            let data = try NSKeyedArchiver.archivedData(withRootObject: image, requiringSecureCoding: true)
            var container = encoder.singleValueContainer()
            try container.encode(data)
        }
    }

#endif
