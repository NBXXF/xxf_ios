//
//   LocalFileDataFectcher.swift
//   xxf_ios
//   支持获取本地文件的缩略图的api
//  Created by xx on 8/19.
//
import Foundation
import QuickLookThumbnailing
import XXFFoundation

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

public final class LocalFileThumbnailDataFetcher: ImageDataFetcher {
    public init() {}

    public func canHandle(request: URLRequest) -> Bool {
        /// 文件类型就行
        return request.url?.isFileURL == true
    }

    public func loadData(request: URLRequest, fetchQueue: OperationQueue, completion: @escaping (Result<Data, any Error>) -> Void) -> any Cancellable {
        let task = LocalFileThumbnailDataTask(request: request, fetchQueue: fetchQueue, completion: completion)
        task.start()
        return task
    }

    // MARK: 加载本地文件缩略图

    /// 异步生成 PDF 缩略图并返回 Data
    final class LocalFileThumbnailDataTask: Cancellable, @unchecked Sendable {
        private let request: URLRequest
        private let fetchQueue: OperationQueue
        private let fileLoadURL: URL
        private var requestOptions: RequestOptions
        private let completion: (Result<Data, any Error>) -> Void
        private var cancelled = false

        private var operationCancellable: OperationCancellable?

        init(request: URLRequest,
             fetchQueue: OperationQueue,
             completion: @escaping (Result<Data, any Error>) -> Void)
        {
            self.request = request
            self.fetchQueue = fetchQueue
            self.completion = completion
            let url = request.url.or(URL.emptyURL)
            requestOptions = RequestOptions(url: url)

            /// 不能影响文件加载
            fileLoadURL = RequestOptions.removeOptions(url: url)

            /// 系统finder 对于图片和视频类型 列表视图都是缩略图
            if let type = UTType(filenameExtension: fileLoadURL.pathExtension.lowercased()) {
                if type.isImageUTType || type.isVideoUTType {
                    requestOptions.representationType(.thumbnail)
                }
            }
        }

        func start() {
            operationCancellable =
                OperationCancellable(BlockOperation {
                    [weak self] in
                    guard let self = self, !self.cancelled else { return }

                    /// 处理大小
                    let size = if self.requestOptions.requestTargetSize != .zero {
                        self.requestOptions.requestTargetSize
                    } else if self.requestOptions.requsetRepresentationType == RepresentationType.icon {
                        CGSize(width: 64, height: 64)
                    } else {
                        CGSize(width: 256, height: 256)
                    }
                    let requestQL = QLThumbnailGenerator.Request(
                        fileAt: self.fileLoadURL,
                        size: size,
                        scale: screenScale,
                        representationTypes: self.requestOptions.requsetRepresentationType.rawTypes
                    )
                    // 当 true 时：生成的表示会带上平台 icon 的装饰（例如框、阴影、可能的背景、或卷角等），适合用作 Finder/桌面那类“文件图标”外观。
                    requestQL.iconMode = true

                    QLThumbnailGenerator.shared.generateBestRepresentation(for: requestQL) { thumbnail, error in
                        guard !self.cancelled else { return }

                        #if canImport(UIKit)
                            if let image = thumbnail?.uiImage,
                               let data = image.pngData()
                            {
                                self.completion(.success(data))
                            } else {
                                if let data = icon.toPNGData() {
                                    self.completion(.success(data))
                                } else {
                                    self.completion(.failure(error ?? AppError("load fail")))
                                }
                            }
                        #elseif canImport(AppKit)
                            if let image = thumbnail?.nsImage,
                               let tiff = image.tiffRepresentation,
                               let bitmap = NSBitmapImageRep(data: tiff),
                               let data = bitmap.representation(using: .png, properties: [:])
                            {
                                self.completion(.success(data))
                            } else {
                                let icon = NSWorkspace.shared.icon(forFile: self.fileLoadURL.path)
                                if let data = icon.toPNGData() {
                                    self.completion(.success(data))
                                } else {
                                    self.completion(.failure(error ?? AppError("load fail")))
                                }
                            }
                        #endif
                    }
                })

            fetchQueue.addOperation(operationCancellable!.operation)
        }

        func cancel() {
            operationCancellable?.cancel()
            cancelled = true
        }
    }
}
