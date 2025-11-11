//

#if canImport(CoreGraphics)

    #if os(macOS)
        import AppKit

        public typealias PlatformImage = NSImage
    #else
        import UIKit

        public typealias PlatformImage = UIImage
        @usableFromInline let kUTTypeJPEG = "public.jpeg" as CFString
        @usableFromInline let kUTTypePNG = "public.png" as CFString
        @usableFromInline let kUTTypeTIFF = "public.tiff" as CFString
        @usableFromInline let kUTTypeGIF = "com.compuserve.gif" as CFString
        @usableFromInline let kUTTypePDF = "com.adobe.pdf" as CFString
    #endif

    // HEIC definition.
    @usableFromInline nonisolated(unsafe) let kUTTypeHEIC = "public.heic" as CFString
    @usableFromInline nonisolated(unsafe) let kUTTypeSVG = "public.svg-image" as CFString

#endif
