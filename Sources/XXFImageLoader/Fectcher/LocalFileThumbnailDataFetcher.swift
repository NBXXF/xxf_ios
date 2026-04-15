//
//  LocalFileDataFectcher.swift
//  xxf_ios
//  支持获取本地文件缩略图
//  Created by xx on 8/19.
//

import Foundation
import QuickLookThumbnailing
import UniformTypeIdentifiers
import XXFFoundation

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

public final class LocalFileThumbnailDataFetcher: ImageDataFetcher {
    public init() {}

    public func canHandle(request: URLRequest) -> Bool {
        request.url?.isFileURL == true
    }

    public func loadData(request: URLRequest,
                         fetchQueue: OperationQueue,
                         completion: @escaping @Sendable (Result<Data, any Error>) -> Void) -> any Cancellable
    {
        let task = LocalFileThumbnailDataTask(request: request, fetchQueue: fetchQueue, completion: completion)
        task.start()
        return task
    }

    // MARK: - 加载本地文件缩略图

    final class LocalFileThumbnailDataTask: Cancellable, @unchecked Sendable {
        private let fetchQueue: OperationQueue
        private let fileLoadURL: URL
        private var requestOptions: RequestOptions
        private let completion: @Sendable (Result<Data, any Error>) -> Void
        private var cancelled = false

        private var operationCancellable: OperationCancellable?

        init(request: URLRequest,
             fetchQueue: OperationQueue,
             completion: @escaping @Sendable (Result<Data, any Error>) -> Void)
        {
            self.fetchQueue = fetchQueue
            self.completion = completion

            let url = request.url.or(URL.emptyURL)
            requestOptions = RequestOptions(url: url)
            fileLoadURL = RequestOptions.removeOptions(url: url)

            // 图片 / 视频默认优先请求 thumbnail 表示，和系统 Finder 一致。
            if let type = UTType(filenameExtension: fileLoadURL.pathExtension.lowercased()),
               (type.isImageUTType || type.isVideoUTType)
            {
                requestOptions.representationType(.thumbnail)
            }
        }

        func start() {
            operationCancellable = OperationCancellable(BlockOperation {
                [weak self] in
                guard let self = self, !self.cancelled else { return }

                let size: CGSize
                if self.requestOptions.requestTargetSize != .zero {
                    size = self.requestOptions.requestTargetSize
                } else if self.requestOptions.requsetRepresentationType == .icon {
                    size = CGSize(width: 64, height: 64)
                } else {
                    size = CGSize(width: 256, height: 256)
                }

                let requestQL = QLThumbnailGenerator.Request(
                    fileAt: self.fileLoadURL,
                    size: size,
                    scale: screenScale,
                    representationTypes: self.requestOptions.requsetRepresentationType.rawTypes
                )
                // true 会保留图标装饰风格，更接近 Finder 的文件图标样式。
                requestQL.iconMode = true

                QLThumbnailGenerator.shared.generateBestRepresentation(for: requestQL) { [weak self] thumbnail, error in
                    guard let self = self, !self.cancelled else { return }

                    #if canImport(UIKit)
                        if let image = thumbnail?.uiImage,
                           let data = image.pngData()
                        {
                            self.completion(.success(data))
                            return
                        }

                        if let data = LocalFileCoverTool.coverDataIfPlayableMedia(for: self.fileLoadURL,targetSize: size)
                        {
                            self.completion(.success(data))
                            return
                        }

                        if let data = try? Data(contentsOf: self.fileLoadURL) {
                            self.completion(.success(data))
                            return
                        }

                        self.completion(.failure(error ?? AppError("thumbnail load fail")))
                    #elseif canImport(AppKit)
                        if let image = thumbnail?.nsImage,
                           let data = image.toPNGData()
                        {
                            self.completion(.success(data))
                            return
                        }

                        if let data = LocalFileCoverTool.coverDataIfPlayableMedia(for: self.fileLoadURL)
                        {
                            self.completion(.success(data))
                            return
                        }

                        let icon = NSWorkspace.shared.icon(forFile: self.fileLoadURL.path)
                        if let data = icon.toPNGData() {
                            self.completion(.success(data))
                            return
                        }

                        self.completion(.failure(error ?? AppError("thumbnail load fail")))
                    #else
                        self.completion(.failure(error ?? AppError("unsupported platform")))
                    #endif
                }
            })

            if let operationCancellable {
                fetchQueue.addOperation(operationCancellable.operation)
            }
        }

        func cancel() {
            operationCancellable?.cancel()
            cancelled = true
        }
    }
}
