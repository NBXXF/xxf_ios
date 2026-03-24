//
//  ImageRequestBuilder.swift
//  xxf_ios
//  支持链式语法
//  Created by xxf on 2026/8/19.
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

    // MARK: - 缩略图参数

    private var thumbnailOptions: ThumbnailOptions?
    private var extraParameters: [String: String] = [:]

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

    // MARK: - 缩略图 API (Glide 风格)

    /// 设置缩略图参数
    /// - Parameter options: 缩略图选项（包含 w, h, q）
    /// - Returns: Self
    @discardableResult
    public func thumbnail(_ options: ThumbnailOptions) -> Self {
        thumbnailOptions = options
        return self
    }

    /// 添加自定义参数到 URL
    /// - Parameter parameters: 参数字典，key 为参数名，value 为参数值
    /// - Returns: Self
    @discardableResult
    public func extraParameters(_ parameters: [String: String]) -> Self {
        extraParameters.merge(parameters) { _, new in new }
        return self
    }

    public func into(_ imageView: PlatformImageView) {
        let rawURL = buildURL()
        adapter.load(url: rawURL,
                     into: imageView,
                     placeholder: placeholder,
                     error: error,
                     queue: queue,
                     progressHandler: progressHandler,
                     completion: completion)
    }

    // MARK: - Private

    private func buildURL() -> URL {
        var params = requestOptions.toOptoionDict()

        // 添加缩略图参数
        if let options = thumbnailOptions {
            if let w = options.w {
                params["w"] = "\(w)"
            }
            if let h = options.h {
                params["h"] = "\(h)"
            }
            if let q = options.q {
                params["q"] = "\(q)"
            }
        }

        // 合并自定义参数
        params.merge(extraParameters) { _, new in new }

        return url.appendingQueryParameters(params)
    }
}
