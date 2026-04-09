//
//  PlatformImageView+ImageLoader.swift
//  xxf_ios
//  图片加载快捷拓展
//  Created by xxf on 2023/8/19.
//

import Foundation

public extension PlatformImageView {
    func load(_ url: URL,
              placeholder: PlatformImage? = nil,
              error: PlatformImage? = nil,
              requestOptions: RequestOptions = .init(),
              queue: DispatchQueue? = nil,
              progressHandler: ((_ completed: Int64, _ total: Int64) -> Void)? = nil,
              completion: ((Result<Void, Swift.Error>) -> Void)? = nil)
    {
        Imageloader.load(url)
            .placeholder(placeholder)
            .error(error)
            .apply(requestOptions)
            .onProgress(queue: queue, progressHandler)
            .onComplete(completion)
            .into(self)
    }

    func load(_ path: String,
              placeholder: PlatformImage? = nil,
              error: PlatformImage? = nil,
              requestOptions: RequestOptions = .init(),
              queue: DispatchQueue? = nil,
              progressHandler: ((_ completed: Int64, _ total: Int64) -> Void)? = nil,
              completion: ((Result<Void, Swift.Error>) -> Void)? = nil)
    {
        Imageloader.load(path)
            .placeholder(placeholder)
            .error(error)
            .apply(requestOptions)
            .onProgress(queue: queue, progressHandler)
            .onComplete(completion)
            .into(self)
    }
}
