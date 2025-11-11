//
//  ImageRequestBuilder.swift
//  xxf_ios
//  支持链式语法
//  Created by xxf on 2025/8/19.
//

import Foundation

public class ImageRequestBuilder {
    private var url: URL
    private let adapter: ImageLoaderAdapter
    private var placeholder: PlatformImage?
    private var error: PlatformImage?
    private var requestOptions: RequestOptions = .init()
    private var queue: DispatchQueue?
    private var progressHandler: ((_ completed: Int64, _ total: Int64) -> Void)?
    private var completion: ((Result<Void, Swift.Error>) -> Void)?

    init(url: URL, adapter: ImageLoaderAdapter) {
        self.url = url
        self.adapter = adapter
    }

    init(path: String, adapter: ImageLoaderAdapter) {
        url = URL(auto: path) ?? URL.emptyURL
        self.adapter = adapter
    }

    public func placeholder(_ image: PlatformImage?) -> Self {
        placeholder = image
        return self
    }

    public func error(_ image: PlatformImage?) -> Self {
        error = image
        return self
    }

    public func apply(_ requestOptions: RequestOptions) -> Self {
        self.requestOptions = requestOptions
        return self
    }

    public func onComplete(_ completion: ((Result<Void, Swift.Error>) -> Void)?) -> Self {
        self.completion = completion
        return self
    }

    public func onProgress(queue: DispatchQueue? = nil, _ progress: ((_ completed: Int64, _ total: Int64) -> Void)?) -> Self {
        self.queue = queue
        progressHandler = progress
        return self
    }

    public func into(_ imageView: PlatformImageView) {
        let rawURL = url.appendingQueryParameters(requestOptions.toOptoionDict())
        adapter.load(url: rawURL,
                     into: imageView,
                     placeholder: placeholder,
                     error: error,
                     queue: queue,
                     progressHandler: progressHandler,
                     completion: completion)
    }
}
