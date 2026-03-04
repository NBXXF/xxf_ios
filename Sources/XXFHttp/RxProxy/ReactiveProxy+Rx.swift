//
//  ReactiveProxy+Rx.swift
//  xxf_ios
//  增加rx代理,主要作用便是拦截
//  Created by xxf on 2025/8/23.
//
import Foundation
import RxSwift

public extension ReactiveProxy where Base: ReactiveCompatible {
    /// 代理请求（直接调用 base.rx.request）
    func request(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Single<Response> {
        let observable: Single<Response> = base.rx.request(token, callbackQueue: callbackQueue)

        // 如果 base 是 HttpMoyaProvider 并且有拦截器
        if let httpProvider = base as? HttpMoyaProvider<Base.Target>,
           let interceptor = httpProvider.callAdapter
        {
            return interceptor.adapt(observable, target: token)
        }

        // 否则直接返回原始请求
        return observable
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
}
