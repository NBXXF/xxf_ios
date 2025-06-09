//
//  MoyaProvider+Stream.swift
//  xxf_ios
//  支持stream 流
//  Created by trl on 2025/6/9.
//

import Alamofire
import Foundation
import Moya

public extension MoyaProvider {
    /// 发起流式请求，返回 Alamofire 的 DataStreamRequest
    ///
    /// - Parameters:
    ///   - target: 请求 Target
    /// - Returns: DataStreamRequest
    private func requestStream(_ target: Target) -> DataStreamRequest {
        do {
            let urlRequest = try endpoint(target).urlRequest()
            // 用 MoyaProvider 的 session 来调用 streamRequest
            return session.streamRequest(urlRequest)
        } catch {
            fatalError("构造 URLRequest 失败: \(error)")
        }
    }

    // MARK: - 下面是 responseStream 系列封装，调用 DataStreamRequest 的对应方法

    /// 原始 Data 流监听，不解析
    ///
    /// - Parameters:
    ///   - target: Moya Target
    ///   - queue: 回调队列，默认.main
    ///   - stream: 流数据回调，多次调用
    /// - Returns: DataStreamRequest
    @preconcurrency
    @discardableResult
    func requestStream(_ target: Target,
                       callbackQueue: DispatchQueue = .main,
                       completion: @escaping DataStreamRequest.Handler<Data, Never>) -> DataStreamRequest
    {
        let streamRequest = requestStream(target)
        streamRequest.responseStream(on: callbackQueue, stream: completion)
        return streamRequest
    }

    /// UTF8 String 流监听
    ///
    /// - Parameters:
    ///   - target: Moya Target
    ///   - queue: 回调队列，默认.main
    ///   - stream: 流数据字符串回调，多次调用
    /// - Returns: DataStreamRequest
    @preconcurrency
    @discardableResult
    func requestStreamString(_ target: Target,
                             callbackQueue: DispatchQueue = .main,
                             completion: @escaping DataStreamRequest.Handler<String, Never>) -> DataStreamRequest
    {
        let streamRequest = requestStream(target)
        streamRequest.responseStreamString(on: callbackQueue, stream: completion)
        return streamRequest
    }

    /// 使用 Serializer 解析流数据
    ///
    /// - Parameters:
    ///   - target: Moya Target
    ///   - serializer: DataStreamSerializer 实现
    ///   - queue: 回调队列，默认.main
    ///   - stream: 流数据回调，Result<Serializer.SerializedObject, AFError>
    /// - Returns: DataStreamRequest
    @preconcurrency
    @discardableResult
    func requestStream<Serializer: DataStreamSerializer>(_ target: Target,
                                                         serializer: Serializer,
                                                         callbackQueue: DispatchQueue = .main,
                                                         completion: @escaping DataStreamRequest.Handler<Serializer.SerializedObject, AFError>) -> DataStreamRequest
    {
        let streamRequest = requestStream(target)
        streamRequest.responseStream(using: serializer, on: callbackQueue, stream: completion)
        return streamRequest
    }

    /// 发起一个流式请求，并将返回的数据流按指定的 Decodable 类型解码。
    ///
    /// 每段数据将使用提供的 `decoder` 解码为指定类型 `T`，通过 `completion` 回调多次返回解析结果。
    ///
    /// - Note: 使用前请确保服务端响应的是逐条 JSON 编码的对象（如 NDJSON 或 JSON 行）或自定义的数据分段协议。
    ///
    /// - Parameters:
    ///   - target: Moya Target，定义请求的接口。
    ///   - type: 解码的目标类型，默认为 `T.self`，即自动推断泛型类型。
    ///   - queue: 响应处理的回调队列，默认是主线程。
    ///   - decoder: 用于解码数据的 `DataDecoder`，默认使用 `JSONDecoder()`。
    ///   - preprocessor: 数据预处理器，默认使用 `PassthroughPreprocessor()`，可对每段数据预处理（如去 BOM）。
    ///   - completion: 流数据的回调，会多次被调用，返回解码后的对象或解码错误。
    ///
    /// - Returns: 返回 `DataStreamRequest` 对象，支持取消或链式操作。
    @preconcurrency
    @discardableResult
    func requestStreamDecodable<T: Decodable & Sendable>(
        _ target: Target,
        type: T.Type = T.self,
        callbackQueue: DispatchQueue = .main,
        decoder: any DataDecoder = JSONDecoder(),
        preprocessor: any DataPreprocessor = PassthroughPreprocessor(),
        completion: @escaping DataStreamRequest.Handler<T, AFError>
    ) -> DataStreamRequest {
        let streamRequest = requestStream(target)
        streamRequest.responseStreamDecodable(of: type, on: callbackQueue, using: decoder, preprocessor: preprocessor, stream: completion)
        return streamRequest
    }
}
