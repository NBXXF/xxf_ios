//
//  MediaMetadata.swift
//  xxf_ios
//  多媒体关键信息获取
//  Created by xxf on 10/11.
//

import AVFoundation
import Foundation
import ImageIO
import UniformTypeIdentifiers

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

public struct MediaAsset: Sendable {
    public let url: URL
    public let type: MediaType
    public let width: Int?
    public let height: Int?
    public let duration: TimeInterval? // 视频 / 音频
}

// MARK: - MediaMetadata 工具类

public enum MediaMetadata {
    // MARK: 单个文件接口

    public static func fetch(from url: URL) -> MediaAsset? {
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
                              duration: nil)

        case .video, .audio:
            let asset = AVAsset(url: url)
            guard let duration = fetchAVDuration(asset: asset) else {
                return nil
            }
            let (w, h) = fetchAVDimensions(asset: asset)
            return MediaAsset(url: url,
                              type: type,
                              width: w,
                              height: h,
                              duration: duration)

        case .unknown:
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
                    try? fetch(from: url)
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
    static func fetchAVDuration(asset: AVAsset) -> TimeInterval? {
        let seconds = CMTimeGetSeconds(asset.duration)
        return seconds.isFinite ? seconds : nil
    }

    /// 获取 AVAsset 视频宽高
    static func fetchAVDimensions(asset: AVAsset) -> (width: Int?, height: Int?) {
        guard let track = asset.tracks(withMediaType: .video).first else { return (nil, nil) }
        let size = track.naturalSize.applying(track.preferredTransform)
        return (Int(abs(size.width)), Int(abs(size.height)))
    }
}
