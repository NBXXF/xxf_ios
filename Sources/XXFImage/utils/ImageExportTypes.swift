//

#if canImport(CoreGraphics)

    import CoreGraphics
    import Foundation

    /// Image export type
    public enum ImageExportType {
        /// PNG export type
        case png(scale: CGFloat = 1, excludeGPSData: Bool = true)
        /// GIF export type
        case gif
        /// JPEG export type
        case jpg(scale: CGFloat = 1, compression: CGFloat? = nil, excludeGPSData: Bool = true)
        /// TIFF export type
        case tiff(scale: CGFloat = 1, compression: CGFloat? = nil, excludeGPSData: Bool = true)
        /// PDF export type
        case pdf(size: CGSize)
        /// HEIC export type. Not supported on macOS < 10.13 (throws an error)
        case heic(scale: CGFloat = 1, compression: CGFloat? = nil, excludeGPSData: Bool = true)
        /// SVG export
        indirect case svg(size: CGSize? = nil, fillStyle: SVGImageFillStyle = .aspectFit, embeddedImageFormat: ImageExportType = .jpg())

        /// The default file extension for the image type
        public var fileExtension: String {
            switch self {
            case .png(scale: _): return "png"
            case .gif: return "gif"
            case .jpg(scale: _, compression: _, excludeGPSData: _): return "jpg"
            case .tiff(scale: _, compression: _, excludeGPSData: _): return "tiff"
            case .pdf(size: _): return "pdf"
            case .heic(scale: _, compression: _, excludeGPSData: _): return "heic"
            case .svg(size: _, fillStyle: _, embeddedImageFormat: _): return "svg"
            }
        }

        /// The raw UTType for each type
        var utType: CFString {
            switch self {
            case .png(scale: _): return kUTTypePNG
            case .gif: return kUTTypeGIF
            case .jpg(scale: _, compression: _, excludeGPSData: _): return kUTTypeJPEG
            case .tiff(scale: _, compression: _, excludeGPSData: _): return kUTTypeTIFF
            case .pdf(size: _): return kUTTypePDF
            case .heic(scale: _, compression: _, excludeGPSData: _): return kUTTypeHEIC
            case .svg(size: _, fillStyle: _, embeddedImageFormat: _): return kUTTypeSVG
            }
        }

        public var mimeType: String {
            switch self {
            case .png(scale: _): return "image/png"
            case .gif: return "image/gif"
            case .jpg(scale: _, compression: _, excludeGPSData: _): return "image/jpeg"
            case .tiff(scale: _, compression: _, excludeGPSData: _): return "image/tiff"
            case .pdf(size: _): return "application/pdf"
            case .heic(scale: _, compression: _, excludeGPSData: _): return "image/heic"
            case .svg(size: _, fillStyle: _, embeddedImageFormat: _): return "image/svg+xml"
            }
        }
    }

#endif
