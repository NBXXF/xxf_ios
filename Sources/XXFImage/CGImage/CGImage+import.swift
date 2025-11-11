//

#if canImport(CoreGraphics)

    import CoreGraphics
    import Foundation

    public extension CGImage {
        /// Load a CGImage from raw image data
        static func load(data: Data) throws -> CGImage {
            guard let image = PlatformImage(data: data)?.cgImage else {
                throw ImageReadWriteError.unableToDecodeImage
            }
            return image
        }

        /// Load a CGImage from a file
        static func load(fileURL: URL) throws -> CGImage {
            assert(fileURL.isFileURL)
            guard let image = PlatformImage(contentsOfFile: fileURL.path)?.cgImage else {
                throw ImageReadWriteError.unableToDecodeImage
            }
            return image
        }

        /// Creates an image object from the specified named asset.
        /// - Parameter name: The image asset name
        /// - Returns: The image
        static func named(_ name: String) throws -> CGImage {
            guard let image = PlatformImage(named: name)?.cgImage else {
                throw ImageReadWriteError.cannotLoadImageNamed(name)
            }
            return image
        }
    }

#endif
