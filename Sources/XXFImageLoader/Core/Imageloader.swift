//
//  Imageloader.swift
//  xxf_ios
//  图片加载,任意图片加载库的上层封装,底层自由切换（可切换nuke或者,kingfisher）
//  Created by xxf on 8/19.
//

import Foundation

private final class NoopImageLoaderAdapter: ImageLoaderAdapter {
    var imageFectchers: [ImageDataFetcher] = []
    var loaderQueue: OperationQueue = .init()

    func load(url _: URL,
              into _: PlatformImageView,
              placeholder _: PlatformImage?,
              error _: PlatformImage?,
              queue _: DispatchQueue?,
              progressHandler _: ((_ completed: Int64, _ total: Int64) -> Void)?,
              completion _: ((Result<Void, Error>) -> Void)?)
    {
        // Release 模式下 adapter 未注入时静默返回，避免崩溃。
    }

    func cancel(view _: PlatformImageView) {}
}

public final class Imageloader {
    /// 需要自行初始化,默认实现有 ImageNukeLoaderAdapter
    public nonisolated(unsafe) static var adapter: ImageLoaderAdapter?

    private init() {}

    private static var activeAdapter: ImageLoaderAdapter {
        if let adapter {
            return adapter
        }
        // Debug 模式触发断言，帮助尽早暴露初始化缺失。
        assertionFailure("Imageloader.adapter is not configured. Please set it during app startup.")
        return NoopImageLoaderAdapter()
    }

    public static func load(_ url: URL) -> ImageRequestBuilder {
        return ImageRequestBuilder(url: url, adapter: activeAdapter)
    }

    public static func load(_ path: String) -> ImageRequestBuilder {
        return ImageRequestBuilder(path: path, adapter: activeAdapter)
    }

    public static func cancel(_ imageView: PlatformImageView) {
        Imageloader.adapter?.cancel(view: imageView)
    }
}
