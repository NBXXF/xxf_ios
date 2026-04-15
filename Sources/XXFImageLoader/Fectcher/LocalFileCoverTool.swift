//
//  LocalFileCoverTool.swift
//  xxf_ios
//  本地文件封面图工具：内部判断视频/音频并返回 PNG 数据
//

import AVFoundation
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

public enum LocalFileCoverTool {
    /// 获取本地可播放媒体（视频/音频）的封面 PNG 数据。
    /// - Parameters:
    ///   - fileURL: 本地文件 URL，必须是普通文件（`file://` 且非目录）。
    ///   - targetSize: 目标封面尺寸，内部会做归一化和上限保护（默认 `1024x1024`）。
    ///   - captureSecond: 视频截帧时间（秒），非法值会回退到默认值 `0.1`。
    ///   - timeout: 单次封面获取超时时间（秒），非法值会回退到默认值 `3`。
    /// - Returns: 成功返回 PNG 数据；非视频/音频或获取失败时返回 `nil`。
    public static func coverDataIfPlayableMedia(for fileURL: URL,
                                                targetSize: CGSize = CGSize(width: 1024, height: 1024),
                                                captureSecond: Double = 0.1,
                                                timeout: TimeInterval = 3) -> Data?
    {
        guard fileURL.isFileURL else { return nil }
        guard isRegularFile(url: fileURL) else { return nil }

        let normalizedSize = normalizeTargetSize(targetSize)
        let normalizedCaptureSecond = normalizeCaptureSecond(captureSecond)
        let normalizedTimeout = normalizeTimeout(timeout)

        switch playableMediaType(for: fileURL) {
            case .video:
                return makeVideoCoverData(url: fileURL,
                                          targetSize: normalizedSize,
                                          captureSecond: normalizedCaptureSecond,
                                          timeout: normalizedTimeout)
            case .audio:
                return makeAudioCoverData(url: fileURL, timeout: normalizedTimeout)
            case .none:
                return nil
        }
    }
}

private extension LocalFileCoverTool {
    static let defaultTargetSize = CGSize(width: 1024, height: 1024)
    static let maxDimension: CGFloat = 4096
    static let defaultCaptureSecond: Double = 0.1
    static let defaultTimeout: TimeInterval = 3

    enum PlayableMediaType {
        case video
        case audio
        case none
    }

    final class DataBox: @unchecked Sendable {
        var value: Data?
    }

    final class VideoGenerationState: @unchecked Sendable {
        private let lock = NSLock()
        private var remainingCount: Int
        private var finished = false
        private var outputData: Data?

        init(remainingCount: Int) {
            self.remainingCount = remainingCount
        }

        func markSuccess(_ data: Data?) -> Bool {
            lock.lock()
            defer { lock.unlock() }
            guard !finished else { return false }
            outputData = data
            finished = true
            return true
        }

        func markFailureAndShouldSignal() -> Bool {
            lock.lock()
            defer { lock.unlock() }
            guard !finished else { return false }
            remainingCount -= 1
            if remainingCount <= 0 {
                finished = true
                return true
            }
            return false
        }

        func markTimedOut() {
            lock.lock()
            finished = true
            lock.unlock()
        }

        func result() -> Data? {
            lock.lock()
            defer { lock.unlock() }
            return outputData
        }
    }

    static func normalizeTargetSize(_ size: CGSize) -> CGSize {
        let width = size.width.isFinite && size.width > 0 ? min(size.width, maxDimension) : defaultTargetSize.width
        let height = size.height.isFinite && size.height > 0 ? min(size.height, maxDimension) : defaultTargetSize.height
        return CGSize(width: width, height: height)
    }

    static func normalizeCaptureSecond(_ second: Double) -> Double {
        guard second.isFinite, second >= 0 else { return defaultCaptureSecond }
        return second
    }

    static func normalizeTimeout(_ timeout: TimeInterval) -> TimeInterval {
        guard timeout.isFinite, timeout > 0 else { return defaultTimeout }
        return min(timeout, 15)
    }

    static func isRegularFile(url: URL) -> Bool {
        if let resourceValues = try? url.resourceValues(forKeys: [.isRegularFileKey]),
           let isRegularFile = resourceValues.isRegularFile
        {
            return isRegularFile
        }
        var isDirectory = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && !isDirectory.boolValue
    }

    static func playableMediaType(for url: URL) -> PlayableMediaType {
        if #available(iOS 14.0, macOS 11.0, *) {
            if let contentType = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType {
                if contentType.conforms(to: .video) ||
                    (contentType.conforms(to: .audiovisualContent) && !contentType.conforms(to: .audio))
                {
                    return .video
                }
                if contentType.conforms(to: .audio) {
                    return .audio
                }
            }
        }

        guard let type = UTType(filenameExtension: url.pathExtension.lowercased()) else {
            return .none
        }
        if type.conforms(to: .video) || (type.conforms(to: .audiovisualContent) && !type.conforms(to: .audio)) {
            return .video
        }
        if type.conforms(to: .audio) {
            return .audio
        }
        return .none
    }

    static func makeVideoCoverData(url: URL,
                                   targetSize: CGSize,
                                   captureSecond: Double,
                                   timeout: TimeInterval) -> Data?
    {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = targetSize

        let semaphore = DispatchSemaphore(value: 0)

        let requestSeconds: [Double] = captureSecond > 0 ? [captureSecond, 0] : [0]
        let requestTimes = requestSeconds.map { NSValue(time: CMTime(seconds: $0, preferredTimescale: 600)) }
        let state = VideoGenerationState(remainingCount: requestTimes.count)

        imageGenerator.generateCGImagesAsynchronously(forTimes: requestTimes) { _, image, _, result, _ in
            if result == .succeeded, let cgImage = image {
                let shouldSignal = state.markSuccess(makePNGData(from: cgImage))
                if shouldSignal {
                    semaphore.signal()
                }
                return
            }

            if state.markFailureAndShouldSignal() {
                semaphore.signal()
            }
        }

        let waitResult = semaphore.wait(timeout: .now() + timeout)
        if waitResult == .timedOut {
            state.markTimedOut()
            imageGenerator.cancelAllCGImageGeneration()
            return nil
        }

        return state.result()
    }

    static func makeAudioCoverData(url: URL, timeout: TimeInterval) -> Data? {
        let output = DataBox()
        let semaphore = DispatchSemaphore(value: 0)

        let task = Task.detached {
            defer { semaphore.signal() }

            let asset = AVURLAsset(url: url)
            guard let commonMetadata = try? await asset.load(.commonMetadata) else { return }
            let artworkItems = AVMetadataItem.metadataItems(from: commonMetadata,
                                                            filteredByIdentifier: .commonIdentifierArtwork)
            for item in artworkItems {
                if Task.isCancelled { return }
                guard let artworkData = try? await item.load(.dataValue),
                      let imageSource = CGImageSourceCreateWithData(artworkData as CFData, nil),
                      let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
                else {
                    continue
                }
                output.value = makePNGData(from: cgImage)
                return
            }
        }

        let waitResult = semaphore.wait(timeout: .now() + timeout)
        if waitResult == .timedOut {
            task.cancel()
            return nil
        }
        task.cancel()
        return output.value
    }

    static func makePNGData(from cgImage: CGImage) -> Data? {
        #if canImport(UIKit)
            return UIImage(cgImage: cgImage).pngData()
        #elseif canImport(AppKit)
            let image = NSImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
            return image.toPNGData()
        #else
            return nil
        #endif
    }
}
