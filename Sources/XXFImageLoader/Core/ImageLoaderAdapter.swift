//
//  ImageLoaderAdapter.swift
//  xxf_ios
//  图片加载适配器
//  Created by xxf on 8/19.
//
import Foundation

public protocol ImageLoaderAdapter {
    /// 数据加载器
    var imageFectchers: [ImageDataFetcher] { get set }

    /// 图片加载的队列
    var loaderQueue: OperationQueue { get set }

    func load(url: URL,
              into view: PlatformImageView,
              placeholder: PlatformImage?,
              error: PlatformImage?,
              queue: DispatchQueue?,
              progressHandler: ((_ completed: Int64, _ total: Int64) -> Void)?,
              completion: ((Result<Void, Swift.Error>) -> Void)?)
    func cancel(view: PlatformImageView)
}
