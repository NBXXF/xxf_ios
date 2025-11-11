//
//  Imageloader.swift
//  xxf_ios
//  图片加载,任意图片加载库的上层封装,底层自由切换（可切换nuke或者,kingfisher）
//  Created by xxf on 8/19.
//

import Foundation

public final class Imageloader {
    /// 需要自行初始化,默认实现有 ImageNukeLoaderAdapter
    public nonisolated(unsafe) static var adapter: ImageLoaderAdapter?

    private init() {}

    public static func load(_ url: URL) -> ImageRequestBuilder {
        return ImageRequestBuilder(url: url, adapter: Imageloader.adapter!)
    }

    public static func load(_ path: String) -> ImageRequestBuilder {
        return ImageRequestBuilder(path: path, adapter: Imageloader.adapter!)
    }

    public static func cancel(_ imageView: PlatformImageView) {
        Imageloader.adapter?.cancel(view: imageView)
    }
}
