//
//  MediaMetadata.swift
//  xxf_ios
//  多媒体关键信息获取
//  Created by xxf on 10/11.
//

import AVFoundation
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers
#if canImport(Photos)
    import Photos
#endif

// MARK: - 媒体类型

public enum MediaType: Equatable, Sendable {
    case image
    case video
    case audio
    case unknown

    public init(for url: URL) {
        self = MediaMetadata.detectMediaType(for: url)
    }
}

// MARK: - 媒体信息

public struct MediaAsset: @unchecked Sendable {
    public let url: URL
    public let type: MediaType
    public let width: Int?
    public let height: Int?
    public let duration: TimeInterval? // 视频 / 音频
}

// MARK: - MediaMetadata 工具类

public enum MediaMetadata {
    /// 是否是动图
    public static func isAnimatedImage(url: URL) -> Bool {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
            return false
        }

        let count = CGImageSourceGetCount(source)
        return count > 1
    }

    // MARK: 单个文件接口

    /// 建议在子线程使用
    public static func fetch(from url: URL) -> MediaAsset? {
        final class ResultBox: @unchecked Sendable {
            var value: MediaAsset?
        }

        let resultBox = ResultBox()
        let semaphore = DispatchSemaphore(value: 0)
        Task.detached {
            resultBox.value = await fetch(from: url)
            semaphore.signal()
        }
        semaphore.wait()
        return resultBox.value
    }

    public static func fetch(from url: URL) async -> MediaAsset? {
        // iOS/macOS Photos 资产标识（ph://<localIdentifier>）优先走 Photos 直取像素信息
        if let photoAsset = fetchPhotoAssetMetadata(from: url) {
            return photoAsset
        }

        // 1. 判断类型
        let type = detectMediaType(for: url)

        switch type {
            case .image:
                let dimensions = fetchImageDimensions(url: url)
                return MediaAsset(url: url,
                                  type: .image,
                                  width: dimensions?.width,
                                  height: dimensions?.height,
                                  duration: nil)

            case .video, .audio:
                let asset = AVURLAsset(url: url)
                let duration = await fetchAVDuration(asset: asset)
                let (w, h) = await fetchAVDimensions(asset: asset)
                return MediaAsset(url: url,
                                  type: type,
                                  width: w,
                                  height: h,
                                  duration: duration)

            case .unknown:
                // 先兜底尝试图片
                if let dimensions = fetchImageDimensions(url: url) {
                    return MediaAsset(url: url,
                                      type: .image,
                                      width: dimensions.width,
                                      height: dimensions.height,
                                      duration: nil)
                }
                // 再兜底尝试 AV 资源（无后缀、临时文件名时常见）
                let asset = AVURLAsset(url: url)
                let duration = await fetchAVDuration(asset: asset)
                let (w, h) = await fetchAVDimensions(asset: asset)
                if duration != nil || w != nil || h != nil {
                    let guessedType = await guessMediaTypeFromAVAsset(asset: asset, fallbackURL: url)
                    return MediaAsset(url: url,
                                      type: guessedType,
                                      width: w,
                                      height: h,
                                      duration: duration)
                }
                return MediaAsset(url: url,
                                  type: .unknown,
                                  width: nil,
                                  height: nil,
                                  duration: nil)
        }
    }

    // MARK: 批量文件接口（并发处理）

    public static func fetch(from urls: [URL]) async -> [MediaAsset] {
        if urls.isEmpty { return [] }
        return await withTaskGroup(of: MediaAsset?.self) { group in
            for url in urls {
                group.addTask {
                    await fetch(from: url)
                }
            }

            var results = [MediaAsset]()
            for await result in group {
                if let asset = result {
                    results.append(asset)
                }
            }
            return results
        }
    }
}

// MARK: - Private Helpers

private extension MediaMetadata {
    // MARK: - Type Detect

    static func detectMediaType(for url: URL) -> MediaType {
        if let type = resourceContentType(for: url) {
            return mediaType(for: type)
        }

        let ext = url.pathExtension
        guard !ext.isEmpty, let type = UTType(filenameExtension: ext.lowercased()) else {
            return .unknown
        }
        return mediaType(for: type)
    }

    static func mediaType(for type: UTType) -> MediaType {
        if type.conforms(to: .image) {
            return .image
        }
        if type.conforms(to: .video) || (type.conforms(to: .audiovisualContent) && !type.conforms(to: .audio)) {
            return .video
        }
        if type.conforms(to: .audio) {
            return .audio
        }
        return .unknown
    }

    static func resourceContentType(for url: URL) -> UTType? {
        #if canImport(Foundation)
            if #available(iOS 14.0, macOS 11.0, *) {
                return try? url.resourceValues(forKeys: [.contentTypeKey]).contentType
            }
        #endif
        return nil
    }

    /// 获取图片宽高（一次性）
    static func fetchImageDimensions(url: URL) -> (width: Int, height: Int)? {
        if let source = CGImageSourceCreateWithURL(url as CFURL, nil),
           let dimensions = fetchImageDimensions(source: source)
        {
            return dimensions
        }

        // 某些 URL（包含 query / 安全沙盒转发）CreateWithURL 失败时，尝试从 Data 读取
        guard let data = try? Data(contentsOf: url),
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let dimensions = fetchImageDimensions(source: source)
        else {
            return nil
        }
        return dimensions
    }

    static func fetchImageDimensions(source: CGImageSource) -> (width: Int, height: Int)? {
        guard let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = numericInt(from: props[kCGImagePropertyPixelWidth]),
              let height = numericInt(from: props[kCGImagePropertyPixelHeight]),
              width > 0,
              height > 0
        else {
            return nil
        }
        return (width, height)
    }

    static func numericInt(from value: Any?) -> Int? {
        switch value {
            case let int as Int:
                return int
            case let number as NSNumber:
                return number.intValue
            case let double as Double:
                return Int(double.rounded())
            case let float as Float:
                return Int(float.rounded())
            case let cgFloat as CGFloat:
                return Int(cgFloat.rounded())
            default:
                return nil
        }
    }

    /// 获取 AVAsset 时长
    static func fetchAVDuration(asset: AVAsset) async -> TimeInterval? {
        guard let duration = try? await asset.load(.duration) else {
            return nil
        }
        let seconds = CMTimeGetSeconds(duration)
        return seconds.isFinite ? seconds : nil
    }

    /// 获取 AVAsset 视频宽高
    static func fetchAVDimensions(asset: AVAsset) async -> (width: Int?, height: Int?) {
        let tracks = (try? await asset.loadTracks(withMediaType: .video)) ?? []
        guard let track = tracks.first else { return (nil, nil) }
        guard let naturalSize = try? await track.load(.naturalSize),
              let preferredTransform = try? await track.load(.preferredTransform)
        else {
            return (nil, nil)
        }
        let size = naturalSize.applying(preferredTransform)
        return (Int(abs(size.width)), Int(abs(size.height)))
    }

    static func guessMediaTypeFromAVAsset(asset: AVAsset, fallbackURL: URL) async -> MediaType {
        let hasVideoTrack = !((try? await asset.loadTracks(withMediaType: .video)) ?? []).isEmpty
        if hasVideoTrack { return .video }

        let hasAudioTrack = !((try? await asset.loadTracks(withMediaType: .audio)) ?? []).isEmpty
        if hasAudioTrack { return .audio }

        return detectMediaType(for: fallbackURL)
    }

    // MARK: - Photos Fallback

    static func fetchPhotoAssetMetadata(from url: URL) -> MediaAsset? {
        #if canImport(Photos)
            guard let localIdentifier = parsePhotoAssetIdentifier(from: url) else {
                return nil
            }

            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
            guard let asset = fetchResult.firstObject else {
                return nil
            }

            let type: MediaType
            switch asset.mediaType {
                case .image:
                type = .image
                case .video:
                type = .video
                case .audio:
                type = .audio
                case .unknown:
                type = .unknown
                @unknown default:
                type = .unknown
            }

            let width = asset.pixelWidth > 0 ? asset.pixelWidth : nil
            let height = asset.pixelHeight > 0 ? asset.pixelHeight : nil
            let duration: TimeInterval? = (type == .video || type == .audio) ? asset.duration : nil
            return MediaAsset(url: url,
                              type: type,
                              width: width,
                              height: height,
                              duration: duration)
        #else
            return nil
        #endif
    }

    static func parsePhotoAssetIdentifier(from url: URL) -> String? {
        guard let scheme = url.scheme?.lowercased(),
              scheme == "ph" || scheme == "photos"
        else {
            return nil
        }

        let host = url.host ?? ""
        var path = url.path
        if path.hasPrefix("/") {
            path.removeFirst()
        }

        var identifier = host
        if !path.isEmpty {
            identifier += host.isEmpty ? path : "/\(path)"
        }

        let decoded = identifier.removingPercentEncoding ?? identifier
        return decoded.isEmpty ? nil : decoded
    }
}
