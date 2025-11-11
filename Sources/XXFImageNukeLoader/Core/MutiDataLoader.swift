//
//  MutiDataFectcher.swift
//  xxf_ios
//  查询匹配第一个的,且是并行的
//  Created by xx on 8/19.
//
import Foundation
import Nuke
import XXFImageLoader

typealias DataLoaderFetcher = DataLoading & ImageDataFetcher
final class MutiDataLoader: DataLoading {
    private let dataLoadingList: [DataLoaderFetcher]

    init(dataLoadingList: [DataLoaderFetcher]) {
        self.dataLoadingList = dataLoadingList
    }

    func loadData(with request: URLRequest, didReceiveData: @escaping (Data, URLResponse) -> Void, completion: @escaping ((any Error)?) -> Void) -> any Nuke.Cancellable {
        return dataLoadingList.first { dataLoading in
            dataLoading.canHandle(request: request)
        }!.loadData(with: request, didReceiveData: didReceiveData, completion: completion)
    }
}
