//
//  ReactiveProxy+Rx.swift
//  xxf_ios
//  增加rx代理,主要作用便是拦截
//  Created by xxf on 2023/8/23.
//
import Foundation
import Moya
import RxSwift

public extension ReactiveProxy where Base: ReactiveCompatible {
    /// 发起请求并返回 `Observable<Response>`。
    ///
    /// 当 `base` 为 `HttpMoyaProvider` 时，请求会经过其内部缓存与拦截适配逻辑，
    /// 以支持缓存策略下的多次发射场景。
    ///
    ///  特别注意,业务更建议用 request<T: Decodable>(_ token: Base.Target, type: T.Type, callbackQueue: DispatchQueue? = nil) 这个api,这样报错跟踪更加友好 并且适合处理rx解析报错; 尤其是concat等等
    /// - Parameters:
    ///   - token: 请求目标。
    ///   - callbackQueue: 回调队列。
    /// - Returns: 请求结果流。
    func request(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Observable<Response> {
        let single: Single<Response> = base.rx.request(token, callbackQueue: callbackQueue)

        // 如果是 HttpMoyaProvider，使用内部的缓存和拦截器处理
        if let httpProvider = base as? HttpMoyaProvider<Base.Target> {
            return httpProvider.adaptRequest(token, single: single)
        }

        // 否则直接返回原始请求
        return single.asObservable()
    }

    /// 发起请求并将响应映射为指定模型。
    ///
    /// - Parameters:
    ///   - token: 请求目标。
    ///   - type: 目标模型类型。
    ///   - callbackQueue: 回调队列。
    /// - Returns: 映射后的模型结果流。
    func request<T: Decodable>(_ token: Base.Target, type: T.Type, callbackQueue: DispatchQueue? = nil) -> Observable<T> {
        ///TODO: 必须在  let single: Single<Response> = base.rx.request(token, callbackQueue: callbackQueue) 这里处理解析 之后才好处理adaptRequest
        return request(token, callbackQueue: callbackQueue)
            .mapHttpResponse(T.self)
    }

    /// 发起带进度的请求并返回 `Observable<ProgressResponse>`。
    ///
    /// 当 `base` 为 `HttpMoyaProvider` 且存在调用适配器时，会对进度流进行拦截适配。
    ///
    /// - Parameters:
    ///   - token: 请求目标。
    ///   - callbackQueue: 回调队列。
    /// - Returns: 进度与响应结果流。
    func requestWithProgress(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Observable<ProgressResponse> {
        let observable: Observable<ProgressResponse> = base.rx.requestWithProgress(token, callbackQueue: callbackQueue)

        // 如果 base 是 HttpMoyaProvider 并且有拦截器
        if let httpProvider = base as? HttpMoyaProvider<Base.Target>,
           let interceptor = httpProvider.callAdapter
        {
            return interceptor.adapt(observable, target: token)
        }

        // 否则直接返回原始请求
        return observable
    }

    /// 发起请求并返回 `Single<Response>`（仅发射一次）。
    ///
    /// - Warning: 已废弃，请使用 `request(_:callbackQueue:)`。
    /// - Parameters:
    ///   - token: 请求目标。
    ///   - callbackQueue: 回调队列。
    /// - Returns: 单次响应结果。
    @available(*, deprecated, message: "This method is deprecated; please use the `request(_:callbackQueue:)` method instead.")
    func requestSingle(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Single<Response> {
        return request(token, callbackQueue: callbackQueue).asSingle()
    }
}
