//
//  NukeDataFetcher.swift
//  xxf_ios
//  Nuke的默认加载器
//  Created by xx on 8/19.
//
import Foundation
import Nuke
import XXFImageLoader

extension DataLoader: ImageDataFetcher {
    public func canHandle(request _: URLRequest) -> Bool {
        return true
    }

    public func loadData(request: URLRequest, fetchQueue _: OperationQueue, completion: @escaping (Result<Data, Swift.Error>) -> Void) -> any XXFImageLoader.Cancellable {
        // 调用 DataLoading 的方法
        let task = loadData(with: request, didReceiveData: { data, _ in
            // 这里可以累加 data 或直接返回
            // 对于普通文件，可以直接回调一次
            completion(.success(data))
        }, completion: { error in
            if let error = error {
                completion(.failure(error))
            }
        })

        return AnyCancellableWrapper(task)
    }
}
