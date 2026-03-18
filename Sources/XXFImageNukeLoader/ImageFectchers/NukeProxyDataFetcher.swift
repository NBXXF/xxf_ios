#if os(iOS)
//
//  NukeProxyDataFetcher.swift
//  xxf_ios
//
//  Created by xx on 8/19.
//

import Foundation
import Nuke
import XXFFoundation
import XXFImageLoader

final class NukeProxyDataFetcher: ImageDataFetcher, DataLoading {
    let proxy: ImageDataFetcher
    init(proxy: ImageDataFetcher) {
        self.proxy = proxy
    }

    func canHandle(request: URLRequest) -> Bool {
        return proxy.canHandle(request: request)
    }

    func loadData(request: URLRequest, fetchQueue: OperationQueue, completion: @escaping @Sendable (Result<Data, any Error>) -> Void) -> any XXFImageLoader.Cancellable {
        return proxy.loadData(request: request, fetchQueue: fetchQueue, completion: completion)
    }

    func loadData(with request: URLRequest,
                  didReceiveData: @escaping @Sendable (Data, URLResponse) -> Void,
                  completion: @escaping @Sendable ((any Error)?) -> Void) -> any Nuke.Cancellable
    {
        // 1. 将 URLRequest 转换为 URL
        guard request.url != nil else {
            completion(AppError("Invalid URL"))
            return EmptyCancellable()
        }

        // 2. 调用 proxy 的 loadData(url:completion:)
        let task = proxy.loadData(request: request, fetchQueue: Imageloader.adapter!.loaderQueue) { result in
            switch result {
                case let .success(data):
                    // 调用 didReceiveData，模拟单次接收全部 Data
                    didReceiveData(data, URLResponse())
                    completion(nil)
                case let .failure(error):
                    completion(error)
            }
        }

        return AnyCancellableWrapper(task)
    }
}
#endif
