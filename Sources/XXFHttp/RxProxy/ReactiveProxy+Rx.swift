//
//  ReactiveProxy+Rx.swift
//  xxf_ios
//  增加rx代理,主要作用便是拦截
//  Created by xxf on 2025/8/23.
//
import Foundation
import Moya
import RxSwift

public extension ReactiveProxy where Base: ReactiveCompatible {
    /// 代理请求（返回 Observable 以支持缓存模式的多次发射）
    ///
    /// 当 Target 实现 CacheableTarget 时，根据 cacheConfig 自动处理缓存：
    /// - `firstCache`: 可能发射 1-2 次（先缓存后网络）
    /// - `lastCache`: 发射 1 次（缓存），静默更新网络
    /// - 其他模式: 发射 1 次
    func request(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Observable<Response> {
        let single: Single<Response> = base.rx.request(token, callbackQueue: callbackQueue)

        // 如果是 HttpMoyaProvider，使用内部的缓存和拦截器处理
        if let httpProvider = base as? HttpMoyaProvider<Base.Target> {
            return httpProvider.adaptRequest(token, single: single)
        }

        // 否则直接返回原始请求
        return single.asObservable()
    }

    /// 代理请求带进度（直接调用 base.rx.requestWithProgress）
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

    /// 代理请求（返回 Single，只发射一次）
    ///
    /// - Warning: 此方法已过时，请使用 `request(_:callbackQueue:)` 方法。
    @available(*, deprecated, message: "此方法已过时，请使用 request(_:callbackQueue:) 方法。")
    func requestSingle(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Single<Response> {
        return request(token, callbackQueue: callbackQueue).asSingle()
    }
}
