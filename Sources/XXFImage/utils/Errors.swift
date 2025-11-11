//

#if canImport(CoreGraphics)

    import Foundation

    public enum ImageReadWriteError: Error {
        case unableToDecodeImage
        case invalidDPI
        case cannotCreateImageOfType(String)
        case cannotCreatePDFContext
        case cannotCreateCGImage
        case codableInvalidData
        case codableInvalidImage
        case cannotConvertCGImageToPlatformImage
        case unsupportedEmbeddedImageType(String)
        case internalError
        case cannotConvertColorspace
        case cannotLoadImageNamed(String)
    }

#endif
