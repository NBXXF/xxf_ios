//

#if canImport(CoreGraphics)

    import Foundation

    #if os(macOS)
        import AppKit.NSImage
    #else
        import UIKit.UIImage
    #endif

    public extension PlatformImage {
        /// Load an image from a file URL
        /// - Parameter fileURL: The url for the file containing the image
        /// - Returns: An image, or nil if the file was not an image
        static func load(fileURL: URL) throws -> PlatformImage {
            assert(fileURL.isFileURL)
            #if os(macOS)
                guard let image = PlatformImage(contentsOf: fileURL) else {
                    throw ImageReadWriteError.unableToDecodeImage
                }
                return image
            #else
                guard let image = PlatformImage(contentsOfFile: fileURL.path) else {
                    throw ImageReadWriteError.unableToDecodeImage
                }
                return image
            #endif
        }

        /// Load an image from raw data
        /// - Parameter data: The data containing the image
        /// - Returns: An image, or nil if the data did not contain an image
        static func load(data: Data) throws -> PlatformImage {
            guard let image = PlatformImage(data: data) else {
                throw ImageReadWriteError.unableToDecodeImage
            }
            return image
        }
    }

#endif
