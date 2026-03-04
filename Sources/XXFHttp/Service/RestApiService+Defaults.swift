//
//  RestApiService+Defaults.swift
//  xxf_ios
//  RestApiService 默认实现
//  Created by xxf on /6/9.
//

import Foundation
import Moya

/// 不要和其他业务queue复用,避免相互影响 超时时间和排队问题
let networkCallbackQueue = DispatchQueue(label: "com.xxf.network.callback.queue",
                                         qos: .utility,
                                         attributes: [.concurrent])

// MARK: - 默认实现

public extension RestApiService {
    /// 默认 Endpoint 规则：将 TargetType 映射为 Endpoint。
    static var endpointClosure: MoyaProvider<Self>.EndpointClosure {
        MoyaProvider<Self>.defaultEndpointMapping
    }

    /// 默认 Request 规则：将 Endpoint 转换为 URLRequest。
    static var requestClosure: MoyaProvider<Self>.RequestClosure {
        MoyaProvider<Self>.defaultRequestMapping
    }

    /// 默认 Stub 行为：永不使用模拟数据（只在测试中建议改写）。
    static var stubClosure: MoyaProvider<Self>.StubClosure {
        MoyaProvider<Self>.neverStub
    }

    /// 默认回调队列：使用 Alamofire 默认队列 , 默认用networkCallbackQueue (官方是主线程不好))。
    static var callbackQueue: DispatchQueue? {
        networkCallbackQueue
    }

    /// 默认 Session：使用 Moya 默认的 Alamofire Session。
    static var session: HttpSession {
        /// MoyaProvider<Self>.defaultAlamofireSession()
        /// 业务默认不应该修改这个default对象, 应该URLSessionConfiguration.default.newBuilder()来复制创建
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        return HttpSession(configuration: configuration,
                           startRequestsImmediately: false)
    }

    /// 拦截器列表：为空，可在服务中自定义返回如 NetworkLoggerPlugin。
    static var interceptors: [Interceptor] {
        []
    }

    /// rxswift拦截器
    static var callAdapter: RxCallAdapter? { nil }

    /// 默认请求去重设置：关闭（多个相同请求会并发）。
    static var trackInflights: Bool {
        false
    }

    /// 处理默认的header
    var headers: [String: String]? { [:] }


    // MARK: - Provider 构建方法

    /// 构建并返回一个 MoyaProvider，使用当前类型定义的静态配置。
    /// - Returns: MoyaProvider<Self>
    static func adaptClient() -> HttpMoyaProvider<Self> {
        HttpMoyaProvider<Self>(
            callAdapter: callAdapter,
            endpointClosure: endpointClosure,
            requestClosure: requestClosure,
            stubClosure: stubClosure,
            callbackQueue: callbackQueue,
            session: session.proxy,
            plugins: interceptors,
            trackInflights: trackInflights
        )
    }
}
