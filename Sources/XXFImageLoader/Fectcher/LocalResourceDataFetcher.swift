//
//  LocalReourceDataFetcher.swift
//  xxf_ios
//  本地图片文件获取,必须nuke:isLocalResourcesSupportEnabled = false // 禁用内部直接读取,这样会走自定义的loaderFecther
//  Created by xxf on 2023/8/19.
//
import XXFFoundation
import XXFImage
#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

extension URL {
    var isLocalResource: Bool {
        scheme == "file" || scheme == "data"
    }
}

public final class LocalResourceDataFetcher: ImageDataFetcher {
    public init() {}

    public func canHandle(request: URLRequest) -> Bool {
        return request.url?.isLocalResource == true
    }

    public func loadData(request: URLRequest, fetchQueue: OperationQueue, completion: @escaping @Sendable (Result<Data, any Error>) -> Void) -> any Cancellable {
        let task = LocalReourceDataTask(request: request, fetchQueue: fetchQueue, completion: completion)
        task.start()
        return task
    }

    // MARK: 加载本地文件缩略图

    final class LocalReourceDataTask: Cancellable, @unchecked Sendable {
        private let request: URLRequest
        private let fetchQueue: OperationQueue
        private let fileLoadURL: URL
        private let completion: @Sendable (Result<Data, any Error>) -> Void
        private var cancelled = false

        private var operationCancellable: OperationCancellable?

        init(request: URLRequest,
             fetchQueue: OperationQueue,
             completion: @escaping @Sendable (Result<Data, any Error>) -> Void)
        {
            self.request = request
            self.fetchQueue = fetchQueue
            self.completion = completion
            /// 不能影响文件加载
            fileLoadURL = request.url.or(URL.emptyURL).removingAllParameters()
        }

        func isImageFile(url: URL) -> Bool {
            // 1. 尝试用 UTType 判断 (iOS 14+/macOS 11+)
            #if canImport(UniformTypeIdentifiers)
                if #available(iOS 14.0, macOS 11.0, *) {
                    if let contentType = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType {
                        return contentType.conforms(to: .image)
                    }
                }
            #endif
            return false
        }

        func start() {
            operationCancellable = OperationCancellable(BlockOperation {
                [weak self] in
                guard let self = self, !self.cancelled else { return }
                do {
                    #if canImport(AppKit)
                        /// macOS: 不是图片就先获取系统图标
                        if !isImageFile(url: fileLoadURL) {
                            let icon = NSWorkspace.shared.icon(forFile: fileLoadURL.path)
                            if let data = icon.toPNGData() {
                                self.completion(.success(data))
                                return
                            }
                        }
                    #endif
                    let data = try Data(contentsOf: fileLoadURL)
                    self.completion(.success(data))
                } catch {
                    self.completion(.failure(error))
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
