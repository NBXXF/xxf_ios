//
//  ImageDataFetcher.swift
//  xxf_ios
//  图片取值器
//  Created by xxf on 8/19.
//

import Foundation

public protocol ImageDataFetcher: Sendable {
    /// 判断能否处理该 URL
    func canHandle(request: URLRequest) -> Bool

    /// 异步加载数据
    func loadData(request: URLRequest, fetchQueue: OperationQueue, completion: @escaping (Result<Data, Swift.Error>) -> Void) -> any Cancellable
}
