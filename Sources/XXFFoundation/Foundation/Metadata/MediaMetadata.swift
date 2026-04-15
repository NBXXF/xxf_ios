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

#if canImport(UIKit)
    import UIKit

    public typealias MediaThumbnailImage = UIImage
#elseif canImport(AppKit)
    import AppKit

    public typealias MediaThumbnailImage = NSImage
#else
    public struct MediaThumbnailImage: @unchecked Sendable {}
#endif

// MARK: - 媒体类型

public enum MediaType: Equatable, Sendable {
    case image
    case video
    case audio
    case unknown

    public init(for url: URL) {
        guard let type = UTType(filenameExtension: url.pathExtension) else {
            self = .unknown
            return
        }
        if type.conforms(to: .image) {
            self = .image
        }
        // 视频类型（包含带音轨的视频，但排除纯音频）
        else if type.conforms(to: .video) || (type.conforms(to: .audiovisualContent) && !type.conforms(to: .audio)) {
            /**
             .quickTimeMovie 可能只直接继承自 .audiovisualContent，而不继承 .video，所以 conforms(to: .video) 返回 false → 导致判为 .unknown。
             */
            self = .video
        } else if type.conforms(to: .audio) {
            self = .audio
        } else {
            self = .unknown
        }
    }
}

// MARK: - 媒体信息

public struct MediaAsset: @unchecked Sendable {
    public let url: URL
    public let type: MediaType
    public let width: Int?
    public let height: Int?
    public let duration: TimeInterval? // 视频 / 音频
    public let thumbnail: MediaThumbnailImage? // 视频 / 音频封面
}

// MARK: - MediaMetadata 工具类

public enum MediaMetadata {
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
        // 1. 判断类型
        let type = MediaType(for: url)

        switch type {
            case .image:
                guard let dimensions = fetchImageDimensions(url: url) else {
                    return nil
                }
                return MediaAsset(url: url,
                                  type: .image,
                                  width: dimensions.width,
                                  height: dimensions.height,
                                  duration: nil,
                                  thumbnail: nil)

            case .video, .audio:
                let asset = AVURLAsset(url: url)
                guard let duration = await fetchAVDuration(asset: asset) else {
                    return nil
                }
                let (w, h) = await fetchAVDimensions(asset: asset)
                let thumbnail = await fetchAVThumbnail(asset: asset, type: type)
                return MediaAsset(url: url,
                                  type: type,
                                  width: w,
                                  height: h,
                                  duration: duration,
                                  thumbnail: thumbnail)

            case .unknown:
                return MediaAsset(url: url,
                                  type: .unknown,
                                  width: nil,
                                  height: nil,
                                  duration: nil,
                                  thumbnail: nil)
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
    /// 获取图片宽高（一次性）
    static func fetchImageDimensions(url: URL) -> (width: Int, height: Int)? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let props = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = props[kCGImagePropertyPixelWidth] as? Int,
              let height = props[kCGImagePropertyPixelHeight] as? Int
        else {
            return nil
        }
        return (width, height)
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

    /// 获取视频/音频缩略图
    static func fetchAVThumbnail(asset: AVAsset, type: MediaType) async -> MediaThumbnailImage? {
        switch type {
            case .video:
                return await fetchVideoThumbnail(asset: asset)
            case .audio:
                return await fetchAudioThumbnail(asset: asset)
            case .image, .unknown:
                return nil
        }
    }

    /// 获取视频首帧作为缩略图
    static func fetchVideoThumbnail(asset: AVAsset) async -> MediaThumbnailImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 1024, height: 1024)

        let time = CMTime(seconds: 0.1, preferredTimescale: 600)
        return await withCheckedContinuation { continuation in
            imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { _, image, _, result, _ in
                guard result == .succeeded, let cgImage = image else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: makePlatformImage(from: cgImage))
            }
        }
    }

    /// 获取音频封面（ID3 Artwork 等）
    static func fetchAudioThumbnail(asset: AVAsset) async -> MediaThumbnailImage? {
        guard let commonMetadata = try? await asset.load(.commonMetadata) else {
            return nil
        }

        let artworkItems = AVMetadataItem.metadataItems(from: commonMetadata,
                                                        filteredByIdentifier: .commonIdentifierArtwork)
        var artworkData: Data?
        for item in artworkItems {
            artworkData = try? await item.load(.dataValue)
            if artworkData != nil {
                break
            }
        }

        guard let data = artworkData,
              let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        else {
            return nil
        }
        return makePlatformImage(from: cgImage)
    }

    static func makePlatformImage(from cgImage: CGImage) -> MediaThumbnailImage? {
        #if canImport(UIKit)
            return UIImage(cgImage: cgImage)
        #elseif canImport(AppKit)
            let size = CGSize(width: cgImage.width, height: cgImage.height)
            return NSImage(cgImage: cgImage, size: size)
        #else
            return nil
        #endif
    }
}
