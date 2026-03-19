#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import Foundation

// MARK: - Cross-platform typealias

#if canImport(UIKit)
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
public typealias PlatformImage = NSImage
#endif

// MARK: - Compress Type

public enum CompressType: Sendable {
    /// 聊天场景，短边上限 800
    case session
    /// 朋友圈/时间线场景，短边上限 1280
    case timeline
}

// MARK: - Compress Listener

public protocol OnCompressListener: AnyObject, Sendable {
    func onStart()
    func onSuccess(_ data: Data)
    func onError(_ error: Error)
}

// MARK: - Compress Error

public enum CompressError: Error, LocalizedError, Sendable {
    case sourceNotSet
    case imageDecodeFailed
    case cgImageMissing
    case jpegCompressFailed

    public var errorDescription: String? {
        switch self {
        case .sourceNotSet: return "No image source was set. Call load() before compressing."
        case .imageDecodeFailed: return "Failed to decode image from the provided source."
        case .cgImageMissing: return "Image has no CGImage backing store."
        case .jpegCompressFailed: return "JPEG compression returned nil."
        }
    }
}

// MARK: - Input Source

public enum CompressSource: @unchecked Sendable {
    case image(PlatformImage)
    case data(Data)
    case file(URL)
    case path(String)
}

// MARK: - Luban

public final class Luban: @unchecked Sendable {

    private var source: CompressSource?
    private var compressType: CompressType = .timeline
    private var targetDir: String?
    private var quality: CGFloat = 0.5
    private weak var listener: OnCompressListener?

    private init() {}

    /// 入口
    public static func with() -> Luban {
        return Luban()
    }

    // MARK: - Chain API

    @discardableResult
    public func load(_ source: CompressSource) -> Luban {
        self.source = source
        return self
    }

    @discardableResult
    public func load(_ image: PlatformImage) -> Luban {
        self.source = .image(image)
        return self
    }

    @discardableResult
    public func load(_ path: String) -> Luban {
        self.source = .path(path)
        return self
    }

    @discardableResult
    public func load(_ fileURL: URL) -> Luban {
        self.source = .file(fileURL)
        return self
    }

    @discardableResult
    public func load(_ data: Data) -> Luban {
        self.source = .data(data)
        return self
    }

    /// 设置压缩类型
    @discardableResult
    public func setCompressType(_ type: CompressType) -> Luban {
        self.compressType = type
        return self
    }

    /// 设置输出目录（launch 写文件时使用）
    @discardableResult
    public func setTargetDir(_ dir: String) -> Luban {
        self.targetDir = dir
        return self
    }

    /// 设置 JPEG 压缩质量，默认 0.5（与微信一致）
    @discardableResult
    public func setQuality(_ quality: CGFloat) -> Luban {
        self.quality = quality
        return self
    }

    /// 设置压缩监听
    @discardableResult
    public func setCompressListener(_ listener: OnCompressListener) -> Luban {
        self.listener = listener
        return self
    }

    // MARK: - Execute

    /// 异步执行压缩，结果通过 listener 回调（主线程）
    public func launch() {
        let source = self.source
        let type = self.compressType
        let quality = self.quality
        let targetDir = self.targetDir
        let listener = self.listener

        DispatchQueue.main.async {
            listener?.onStart()
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                guard let source else {
                    throw CompressError.sourceNotSet
                }
                let data: Data = try autoreleasepool {
                    let image = try Self.resolveImage(from: source)
                    return try Self.compressImage(image, type: type, quality: quality)
                }

                if let dir = targetDir {
                    let fileName = UUID().uuidString + ".jpg"
                    let fileURL = URL(fileURLWithPath: dir).appendingPathComponent(fileName)
                    try data.write(to: fileURL)
                }

                DispatchQueue.main.async {
                    listener?.onSuccess(data)
                }
            } catch {
                DispatchQueue.main.async {
                    listener?.onError(error)
                }
            }
        }
    }

    /// 同步压缩，返回 Data
    public func get() throws -> Data {
        guard let source else {
            throw CompressError.sourceNotSet
        }
        let type = self.compressType
        let quality = self.quality
        return try autoreleasepool {
            let image = try Self.resolveImage(from: source)
            return try Self.compressImage(image, type: type, quality: quality)
        }
    }

    /// async/await 压缩
    public func compress() async throws -> Data {
        let source = self.source
        let type = self.compressType
        let quality = self.quality

        guard let source else {
            throw CompressError.sourceNotSet
        }

        return try await Task.detached(priority: .userInitiated) {
            try autoreleasepool {
                let image = try Self.resolveImage(from: source)
                return try Self.compressImage(image, type: type, quality: quality)
            }
        }.value
    }

    // MARK: - Core（WXImageCompress 算法）

    private static func resolveImage(from source: CompressSource) throws -> PlatformImage {
        switch source {
        case .image(let img):
            return img
        case .data(let data):
            guard let img = PlatformImage(data: data) else { throw CompressError.imageDecodeFailed }
            return img
        case .file(let url):
            let data = try Data(contentsOf: url)
            guard let img = PlatformImage(data: data) else { throw CompressError.imageDecodeFailed }
            return img
        case .path(let path):
            #if canImport(UIKit)
            guard let img = PlatformImage(contentsOfFile: path) else { throw CompressError.imageDecodeFailed }
            return img
            #elseif canImport(AppKit)
            guard let img = NSImage(contentsOfFile: path) else { throw CompressError.imageDecodeFailed }
            return img
            #endif
        }
    }

    /// 核心压缩：先缩放到目标尺寸，再 JPEG 压缩
    private static func compressImage(_ image: PlatformImage, type: CompressType, quality: CGFloat) throws -> Data {
        let cgImage = try Self.getCGImage(from: image)
        let originalSize = CGSize(width: cgImage.width, height: cgImage.height)
        let targetSize = Self.calculateSize(originalSize: originalSize, type: type)
        let resized = try Self.resizedImage(cgImage: cgImage, orientation: Self.imageOrientation(image), size: targetSize)
        guard let data = Self.jpegData(from: resized, quality: quality) else {
            throw CompressError.jpegCompressFailed
        }
        return data
    }

    // MARK: - Platform Helpers

    private static func getCGImage(from image: PlatformImage) throws -> CGImage {
        #if canImport(UIKit)
        guard let cg = image.cgImage else { throw CompressError.cgImageMissing }
        return cg
        #elseif canImport(AppKit)
        guard let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            throw CompressError.cgImageMissing
        }
        return cg
        #endif
    }

    #if canImport(UIKit)
    private static func imageOrientation(_ image: PlatformImage) -> UIImage.Orientation {
        return image.imageOrientation
    }
    #elseif canImport(AppKit)
    private static func imageOrientation(_ image: PlatformImage) -> Int {
        return 0 // NSImage 不携带 orientation 信息
    }
    #endif

    private static func jpegData(from cgImage: CGImage, quality: CGFloat) -> Data? {
        #if canImport(UIKit)
        return UIImage(cgImage: cgImage).jpegData(compressionQuality: quality)
        #elseif canImport(AppKit)
        let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
        return bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: quality])
        #endif
    }

    // MARK: - 尺寸计算（与 WXImageCompress 算法完全一致）

    private static func calculateSize(originalSize: CGSize, type: CompressType) -> CGSize {
        var width = originalSize.width
        var height = originalSize.height

        var boundary: CGFloat = 1280

        // 宽高都 <= boundary，保持原尺寸
        guard width > boundary || height > boundary else {
            return CGSize(width: width, height: height)
        }

        let ratio = max(width, height) / min(width, height)
        if ratio <= 2 {
            // 较大边设为 boundary，较小边等比缩放
            let scale = max(width, height) / boundary
            if width > height {
                width = boundary
                height = height / scale
            } else {
                height = boundary
                width = width / scale
            }
        } else {
            // 宽高比 > 2
            if min(width, height) >= boundary {
                // 两边都 >= boundary：较小边设为 boundary
                boundary = type == .session ? 800 : 1280
                let scale = min(width, height) / boundary
                if width < height {
                    width = boundary
                    height = height / scale
                } else {
                    height = boundary
                    width = width / scale
                }
            }
            // 较小边 < boundary：保持原尺寸
        }
        return CGSize(width: width, height: height)
    }

    /// 缩放图片到指定尺寸
    #if canImport(UIKit)
    private static func resizedImage(cgImage: CGImage, orientation: UIImage.Orientation, size: CGSize) throws -> CGImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let uiImage = renderer.image { _ in
            let orientedImage = UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
            orientedImage.draw(in: CGRect(origin: .zero, size: size))
        }
        guard let result = uiImage.cgImage else { throw CompressError.cgImageMissing }
        return result
    }
    #elseif canImport(AppKit)
    private static func resizedImage(cgImage: CGImage, orientation: Int, size: CGSize) throws -> CGImage {
        guard let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw CompressError.cgImageMissing
        }
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let result = context.makeImage() else { throw CompressError.cgImageMissing }
        return result
    }
    #endif
}

// MARK: - PlatformImage 便捷扩展

public extension PlatformImage {

    /// 微信风格压缩（与 WXImageCompress 算法一致）
    func lubanCompress(type: CompressType = .timeline, quality: CGFloat = 0.5) -> Data? {
        return try? Luban.with()
            .load(self)
            .setCompressType(type)
            .setQuality(quality)
            .get()
    }
}
