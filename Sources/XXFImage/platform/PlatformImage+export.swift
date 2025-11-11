//

// Extensions for the platform image types (NSImage, UIImage)

#if canImport(CoreGraphics)

    import CoreGraphics
    import Foundation

    #if os(macOS)
        import AppKit
    #else
        import UIKit
    #endif

    // MARK: - Export

    public extension PlatformImage {
        /// Return the image data in the required format
        /// - Parameter type: The format type to export (with options)
        /// - Returns: The formatted data
        @inlinable func imageData(for type: ImageExportType) throws -> Data {
            guard let image = cgImage else {
                throw ImageReadWriteError.cannotCreateCGImage
            }
            return try image.imageData(for: type)
        }
    }

    public extension PlatformImage {
        struct ImageRepresentation {
            @usableFromInline let owner: PlatformImage
            fileprivate init(_ owner: PlatformImage) {
                self.owner = owner
            }

            /// Create a png representation of the image
            /// - Parameters:
            ///   - dpi: The image's dpi
            ///   - excludeGPSData: Strip any gps data
            /// - Returns: image data
            @inlinable public func png(dpi: CGFloat, excludeGPSData: Bool = false) throws -> Data {
                try owner.imageData(for: .png(scale: dpi / 72.0, excludeGPSData: excludeGPSData))
            }

            /// Create a png representation of the image
            /// - Parameters:
            ///   - scale: The image's scale value
            ///   - excludeGPSData: Strip any gps data
            /// - Returns: image data
            @inlinable public func png(scale: CGFloat = 1, excludeGPSData: Bool = false) throws -> Data {
                try owner.imageData(for: .png(scale: scale, excludeGPSData: excludeGPSData))
            }

            /// Create a jpeg representation of the image
            /// - Parameters:
            ///   - dpi: The image's dpi
            ///   - compression: The compression level to apply (clamped to 0 ... 1)
            ///   - excludeGPSData: Strip any gps data
            /// - Returns: image data
            @inlinable public func jpeg(dpi: CGFloat, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
                try owner.imageData(for: .jpg(scale: dpi / 72.0, compression: compression, excludeGPSData: excludeGPSData))
            }

            /// Create a jpeg representation of the image
            /// - Parameters:
            ///   - scale: The image's scale value
            ///   - compression: The compression level to apply (clamped to 0 ... 1)
            ///   - excludeGPSData: Strip any gps data
            /// - Returns: image data
            @inlinable public func jpeg(scale: CGFloat = 1, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
                try owner.imageData(for: .jpg(scale: scale, compression: compression, excludeGPSData: excludeGPSData))
            }

            /// Create a tiff representation of the image
            /// - Parameters:
            ///   - dpi: The image's dpi
            ///   - compression: The compression level to apply (clamped to 0 ... 1)
            ///   - excludeGPSData: Strip any gps data
            /// - Returns: image data
            @inlinable public func tiff(dpi: CGFloat, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
                try owner.imageData(for: .tiff(scale: dpi / 72.0, compression: compression, excludeGPSData: excludeGPSData))
            }

            /// Create a tiff representation of the image
            /// - Parameters:
            ///   - scale: The image's scale value (for retina-type images eg. @2x == 2)
            ///   - compression: The compression level to apply (clamped to 0 ... 1)
            ///   - excludeGPSData: Strip any gps data
            /// - Returns: image data
            @inlinable public func tiff(scale: CGFloat = 1, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
                try owner.imageData(for: .tiff(scale: scale, compression: compression, excludeGPSData: excludeGPSData))
            }

            /// Create a gif representation of the image
            /// - Returns: image data
            @inlinable public func gif() throws -> Data {
                try owner.imageData(for: .gif)
            }

            /// Create a heic representation of the image
            /// - Parameters:
            ///   - scale: The image's scale value (for retina-type images eg. @2x == 2)
            ///   - compression: The compression level to apply (clamped to 0 ... 1)
            ///   - excludeGPSData: Strip any gps data
            /// - Returns: image data
            @inlinable public func heic(dpi: CGFloat, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
                try owner.imageData(for: .heic(scale: dpi / 72.0, compression: compression, excludeGPSData: excludeGPSData))
            }

            /// Create a heic representation of the image
            /// - Parameters:
            ///   - scale: The image's scale value (for retina-type images eg. @2x == 2)
            ///   - compression: The compression level to apply (clamped to 0 ... 1)
            ///   - excludeGPSData: Strip any gps data
            /// - Returns: image data
            @inlinable public func heic(scale: CGFloat = 1, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
                try owner.imageData(for: .heic(scale: scale, compression: compression, excludeGPSData: excludeGPSData))
            }

            /// Generate a PDF representation of this image
            /// - Parameter size: The output size in pixels
            /// - Returns: PDF data
            @inlinable public func pdf(size: CGSize) throws -> Data {
                try owner.imageData(for: .pdf(size: size))
            }

            /// Generate a SVG representation of this image
            /// - Parameters:
            ///   - size: The output size in pixels (default to the image size)
            ///   - fillStyle: The scaling to apply to the image within the size
            ///   - embeddingType: The svg embedded image type (eg. jpg, png etc)
            /// - Returns: SVG data
            @inlinable public func svg(size: CGSize? = nil, fillStyle: SVGImageFillStyle = .aspectFit, embeddedImageFormat: ImageExportType = .jpg()) throws -> Data {
                try owner.imageData(for: .svg(size: size, fillStyle: fillStyle, embeddedImageFormat: embeddedImageFormat))
            }

            /// Create raw data representation of the image in a specified UTType format
            /// - Parameters:
            ///   - uniformTypeIdentifier: The UTI for the image type to export
            ///   - scale: The image's scale value (for retina-type images eg. @2x == 2)
            ///   - compression: The compression level to apply (clamped to 0 ... 1)
            ///   - excludeGPSData: Strip any gps data
            ///   - otherOptions: Other options as defined in [documentation](https://developer.apple.com/documentation/imageio/cgimagedestination)
            /// - Returns: image data
            @inlinable public func rawImageData(
                uniformTypeIdentifier: String,
                scale: CGFloat = 1,
                compression: CGFloat? = nil,
                excludeGPSData: Bool = false,
                otherOptions: [String: Any]? = nil
            ) throws -> Data {
                guard let image = owner.cgImage else {
                    throw ImageReadWriteError.cannotCreateCGImage
                }
                return try image.representation.rawImageData(
                    uniformTypeIdentifier: uniformTypeIdentifier,
                    scale: scale,
                    compression: compression,
                    excludeGPSData: excludeGPSData,
                    otherOptions: otherOptions
                )
            }
        }

        /// Returns a representation object which can export image types
        var representation: ImageRepresentation { ImageRepresentation(self) }
    }

#endif
