#if os(iOS)
//
//  ImageNukeLoaderAdapter.swift
//  xxf_ios
//  用Nuke 实现ImageLoader的适配器
//  Created by xxf on 8/19.
//
import Foundation
import Nuke
import SDWebImage
import SDWebImageWebPCoder
import XXFFoundation
import XXFImageLoader

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
        // 全局一次性配置:动图 coder + Nuke 解码器数据透传
        _ = Self.setupOnce

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
            // 显式声明:磁盘缓存只存原始下载字节,不做二次编码。
            // 对动图至关重要 —— 若走 .storeEncodedImages / .automatic+processor,
            // Nuke 会把首帧 UIImage 再编码成 JPEG 落盘,动图原始数据就丢了,
            // 下次命中读回来就拿不到 SDAnimatedImage 需要的多帧字节。
            $0.dataCachePolicy = .storeOriginalData
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
            Self.display(placeholder, data: nil, in: view)
        }
        if url.isFileURL {
            // fileURLCacheKey 会 stat 文件,放后台队列避免阻塞主线程
            loaderQueue.addOperation { [weak self, weak view] in
                guard let self, view != nil else { return }
                let key = Self.fileURLCacheKey(url: url)
                Task { @MainActor [weak view] in
                    guard let view else { return }
                    let request = ImageRequest(url: url, userInfo: [.imageIdKey: key])
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
                    // 加载端在后台解码队列预构造好的动图对象(SDAnimatedImage)。
                    // 非空时消费端直接赋图,避免主线程重复解码。
                    let prebuilt = response.container.userInfo[.xxfAnimatedImage] as? UIImage
                    Self.display(response.image, data: response.container.data, animatedImage: prebuilt, in: view)
                    completion?(.success(()))
                case let .failure(err):
                    Self.display(error, data: nil, in: view)
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
        // 停动画、保留当前帧:
        // - UIImageView.stopAnimating() 对非动画态是 no-op
        // - SDAnimatedImageView.stopAnimating() 会撤掉 CADisplayLink 并暂停帧推进
        // 不再走 `Self.display(view.image, ...)` —— 把当前 SDAnimatedImage
        // 再赋一次 `view.image` 会触发 setImage: 重新挂 CADisplayLink,动画会被重启。
        view.stopAnimating()
    }

    /// 统一下发通道:
    /// - 优先下发给 `AnimatedImageDisplaying`(如 `AnimatedImageView`),
    ///   让它按 `animatedImage` / `data` 决定播放或静态展示。
    /// - 否则直接赋 `view.image`(对 UIImageView 即原生行为,等价于 Nuke
    ///   `nuke_display` 默认实现,因此无需再依赖 NukeExtensions)。
    @MainActor
    private static func display(_ image: PlatformImage?,
                                data: Data?,
                                animatedImage: UIImage? = nil,
                                in view: PlatformImageView)
    {
        if let animated = view as? AnimatedImageDisplaying {
            animated.displayImage(image, data: data, animatedImage: animatedImage)
        } else {
            view.image = image
        }
    }

    // MARK: - One-time global setup

    /// 进程级一次性初始化。Swift 的 static let 天然 thread-safe + lazy。
    ///
    /// - 向 SDWebImage coder 链注册 libwebp 解码器,`SDAnimatedImage(data:)` 才能吃动图 WebP。
    /// - 向 Nuke 解码器注册表追加一个 passthrough 解码器,对 WebP / HEIC 这类
    ///   Nuke 默认不保留 `container.data` 的格式,补上原始字节,
    ///   下游 `AnimatedImageView.displayImage` 才能基于 data 构造 SDAnimatedImage。
    private static let setupOnce: Void = {
        // 1) SDWebImage 动图 WebP coder
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)

        // 2) 动图解码器:覆盖所有 SDAnimatedImage 能吃的格式(GIF / WebP / HEIC)
        //    - 在 Nuke 的 imageDecodingQueue(后台)预构造 SDAnimatedImage,消费端主线程零解码
        //    - 在 container.userInfo 中回填原始字节 + 预构造动图 + skip-decompression 标志
        ImageDecoderRegistry.shared.register { context -> (any ImageDecoding)? in
            guard context.isCompleted, let type = AssetType(context.data) else { return nil }
            if type == .gif || type == .webp || type == .heic {
                return AnimatedImageDecoder()
            }
            return nil
        }
    }()
}

/// 动图解码器:基于 Nuke 默认解码器首帧 + 后台线程预构造 SDAnimatedImage。
///
/// - `container.image`:首帧 UIImage(来自 ImageIO / libwebp),兼容纯 UIImageView 消费
/// - `container.data`:原始字节,供其他自管动图的渲染器使用
/// - `container.userInfo[.xxfAnimatedImage]`:预构造的 SDAnimatedImage,主线程零解码路径
/// - `container.userInfo[.xxfSkipDecompression]`:动图由 SDAnimatedImageView 自管帧,
///   Nuke 的 `decompressed()` 对首帧做位图展开是无效功(浪费约 W×H×4 字节内存 + CPU),
///   通过 Nuke 的 skip-decompression hook 跳过。
private final class AnimatedImageDecoder: ImageDecoding, @unchecked Sendable {
    private let base = ImageDecoders.Default()

    func decode(_ data: Data) throws -> ImageContainer {
        var container = try base.decode(data)
        container.data = data
        if let animated = SDAnimatedImage(data: data) {
            container.userInfo[.xxfAnimatedImage] = animated
            container.userInfo[.xxfSkipDecompression] = true
        }
        return container
    }
}

private extension ImageContainer.UserInfoKey {
    /// 预构造好的动图 UIImage(如 SDAnimatedImage)。加载端在解码队列构造,消费端直接赋图。
    static let xxfAnimatedImage: ImageContainer.UserInfoKey = "com.xxf.imagenukeloader.animatedImage"
    /// Nuke 内部的 skip-decompression 信号,字面量与 Nuke 源码 `ImageContainer.isThumbnailKey`
    /// 保持一致。若 Nuke 大版本更新了这个 key,动图会回退到"解压缩+丢弃"的低效路径,
    /// 但不会 crash,behaviorally safe。
    static let xxfSkipDecompression: ImageContainer.UserInfoKey = "com.github/kean/nuke/skip-decompression"
}
#endif
