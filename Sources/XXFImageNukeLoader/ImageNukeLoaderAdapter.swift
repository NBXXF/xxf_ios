#if os(iOS)
//
//  ImageNukeLoaderAdapter.swift
//  xxf_ios
//  用Nuke 实现ImageLoader的适配器
//  Created by xxf on 8/19.
//
import Foundation
import Nuke
import ObjectiveC.runtime
import XXFFoundation
import XXFImageLoader

private nonisolated(unsafe) var kImageTaskKey: UInt8 = 0

public final class ImageNukeLoaderAdapter: @preconcurrency ImageLoaderAdapter {
    public var loaderQueue: OperationQueue

    public var imageFectchers: [any XXFImageLoader.ImageDataFetcher] = [] {
        didSet {
            initNuke()
        }
    }

    public init(loaderQueue: OperationQueue = OperationQueue().apply { loaderQueue in
        loaderQueue.name = "com.xxf.image.loader.nuke.OperationQueue"
        loaderQueue.maxConcurrentOperationCount = 8 // 限制并发
    }) {
        self.loaderQueue = loaderQueue
        imageFectchers = [
            LocalFileThumbnailDataFetcher(),
            LocalResourceDataFetcher()
        ]
        initNuke()
    }

    private func initNuke() {
        var rawList: [DataLoaderFetcher] = imageFectchers.map { item in
            NukeProxyDataFetcher(proxy: item)
        }

        /// 追加一个默认的
        rawList.add(DataLoader())

        /// 初始化 nuke
        ImagePipeline.shared = ImagePipeline {
            // 🔹 本地 IO 很快，开大点没问题
            $0.dataLoadingQueue.maxConcurrentOperationCount = 8

            // 🔹 解码占 CPU，开到一半核心数合适
            $0.imageDecodingQueue.maxConcurrentOperationCount = 4

            // 🔹 解压缩准备绘制，适当并发提升首帧速度
            $0.imageDecompressingQueue.maxConcurrentOperationCount = 4
            $0.isDecompressionEnabled = true
            $0.isUsingPrepareForDisplay = true // macOS/iOS 15+

            // 🔹 图片处理 (Resize 等)，适中就好
            $0.imageProcessingQueue.maxConcurrentOperationCount = 3

            // 🔹 编码（保存用的，不常用）
            $0.imageEncodingQueue.maxConcurrentOperationCount = 1

            $0.dataLoader = MutiDataLoader(dataLoadingList: rawList)
            $0.isLocalResourcesSupportEnabled = false // 禁用内部直接读取,这样会走自定义的loaderFecther
            $0.dataCache = try? DataCache(name: "XXFImageCache") { key in
                // key 默认是 URL.absoluteString
                // 文件内容变更会影响缩略图,这里按时间来计算
                if let url = URL(string: key), url.isFileURL {
                    return ImageNukeLoaderAdapter.fileURLCacheKey(url: url)
                }
                return key.toXXH3String()
            }
        }
    }

    private static func fileURLCacheKey(url: URL) -> String {
        return tryOrLogNil {
            let date = url.stFileTimes()
            /// 路径+时间, 后缀可能会变,所以加path ; 内容改变 主要是缩略图应该随着变化
            return "\(url.path)_\(date.combinedString(using: [\.creationTime, \.modificationTime]))".toXXH3String()
        } ?? url.absoluteString.toXXH3String()
    }

    @MainActor
    public func load(url: URL,
                     into view: PlatformImageView,
                     placeholder: PlatformImage?,
                     error: PlatformImage?,
                     queue: DispatchQueue?,
                     progressHandler: ((Int64, Int64) -> Void)?,
                     completion: ((Result<Void, Swift.Error>) -> Void)?)
    {
        // 取消之前的任务,否则容易有并发错位的问题
        view.nukeImageTask?.cancel()

        // 设置占位图,且避免占位图为空 进行闪缩
        if placeholder != nil {
            view.image = placeholder
        }
        if url.isFileURL {
            Imageloader.adapter!.loaderQueue.addOperation {
                var userInfo: [ImageRequest.UserInfoKey: Any] = [:]
                userInfo[.imageIdKey] = ImageNukeLoaderAdapter.fileURLCacheKey(url: url)

                let request = ImageRequest(url: url, userInfo: userInfo)

                // 先进行内存缓存命中直接显示
                //            let firstCache = false
                //            if firstCache, let cached = ImagePipeline.shared.cache.cachedImage(for: request, caches: .memory) {
                //                view.image = cached.image
                //            } else {
                //
                //            }
                // 切回主线程调用 MainActor 的 load
                Task { @MainActor in
                    self.load(request: request, into: view, error: error, queue: queue, progressHandler: progressHandler, completion: completion)
                }
            }
        } else {
            let request = ImageRequest(url: url)
            load(request: request, into: view, error: error, queue: queue, progressHandler: progressHandler, completion: completion)
        }
    }

    @MainActor private func load(request: ImageRequest,
                                 into view: PlatformImageView,
                                 error: PlatformImage?,
                                 queue: DispatchQueue?,
                                 progressHandler: ((Int64, Int64) -> Void)?,
                                 completion: ((Result<Void, Swift.Error>) -> Void)?)
    {
        /// 在进行数据请求
        /// 唯一请求id
        let requestId = UUID()
        view.nukeRequestId = requestId

        // 先占位，避免闭包提前捕获错误
        let task: ImageTask = ImagePipeline.shared.loadImage(with: request, queue: queue, progress: { _, completed, total in
            if let progressHandler = progressHandler {
                progressHandler(completed, total)
            }
        }) { [weak view] result in
            guard let view = view else { return }

            // 确保不错位
            guard view.nukeRequestId == requestId else {
                return
            } // 核心保证唯一性

            switch result {
                case let .success(response):
                    view.image = response.image
                    completion?(.success(()))
                case let .failure(err):
                    view.image = error
                    completion?(.failure(err))
            }

            // 完成后清理 task
            view.nukeImageTask = nil
            view.nukeRequestId = nil
        }

        // 保存 task 到关联对象
        view.nukeImageTask = task
    }

    @MainActor
    public func cancel(view: XXFImageLoader.PlatformImageView) {
        view.nukeImageTask?.cancel()
        view.nukeImageTask = nil
        view.nukeRequestId = nil
    }
}
#endif
