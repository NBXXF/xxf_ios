//
//  SuperMoyaProvider.swift
//  xxf_ios
//  继承 将publicCallbackQueue公开,官方默认是他的库内可见
//  Created by xxf on 8/23.
//
import Foundation
import Moya
import RxSwift

public final class HttpMoyaProvider<Target: TargetType>: MoyaProvider<Target> {
    public let publicCallbackQueue: DispatchQueue?
    public let callAdapter: RxCallAdapter?

    /// 内部缓存适配器
    private let cacheAdapter = CachingRxCallAdapter.shared

    public init(
        callAdapter: RxCallAdapter? = nil,
        endpointClosure: @escaping EndpointClosure = HttpMoyaProvider.defaultEndpointMapping,
        requestClosure: @escaping RequestClosure = HttpMoyaProvider.defaultRequestMapping,
        stubClosure: @escaping StubClosure = MoyaProvider.neverStub,
        callbackQueue: DispatchQueue? = nil,
        session: Session = MoyaProvider<Target>.defaultAlamofireSession(),
        plugins: [PluginType] = [],
        trackInflights: Bool = false
    ) {
        publicCallbackQueue = callbackQueue
        self.callAdapter = callAdapter

        super.init(endpointClosure: endpointClosure,
                   requestClosure: requestClosure,
                   stubClosure: stubClosure,
                   callbackQueue: callbackQueue,
                   session: session,
                   plugins: plugins,
                   trackInflights: trackInflights)
    }

    /// 处理请求，自动应用缓存策略和拦截器
    /// - Parameters:
    ///   - token: 请求目标
    ///   - single: 原始网络请求
    /// - Returns: 处理后的 Observable（支持缓存多次发射）
    func adaptRequest(_ token: Target, single: Single<Response>) -> Observable<Response> {
        // 检查是否需要缓存处理
        let needsCache = (token as? any RestApiService)?.cachePolicy.needsCache ?? false

        // 如果用户自定义的 callAdapter 是 CachingRxCallAdapter，则由它处理缓存，避免重复
        let userAdapterHandlesCache = callAdapter is CachingRxCallAdapter

        var result: Observable<Response>

        if needsCache && !userAdapterHandlesCache {
            // 使用内部缓存适配器处理
            result = cacheAdapter.adaptToObservable(single, target: token)
        } else {
            result = single.asObservable()
        }

        // 应用用户自定义的拦截器
        if let adapter = callAdapter {
            return adapter.adapt(result, target: token)
        }

        return result
    }
}
