//
//  RestApiService.swift
//  xxf_ios
//  ApiService简化配置
//  Created by xxf on /6/9.
//

import Foundation
import Moya
import XXFFlow

/// API 服务协议：所有 API 枚举（如 UserApiService）应继承此协议。
/// 提供统一的 MoyaProvider 构建机制，并支持通过静态属性配置。
public protocol RestApiService: BaseApiService {
    /// Endpoint 构建闭包：用于将 Target 转换为 Endpoint（URL、任务等）。
    static var endpointClosure: MoyaProvider<Self>.EndpointClosure { get }

    /// Request 构建闭包：用于将 Endpoint 转换为 URLRequest。
    static var requestClosure: MoyaProvider<Self>.RequestClosure { get }

    /// Stub 策略闭包：用于决定是否模拟返回数据。
    static var stubClosure: MoyaProvider<Self>.StubClosure { get }

    /// 默认回调队列：使用 Alamofire 默认队列 , 默认用networkCallbackQueue (官方是主线程不好))。
    static var callbackQueue: DispatchQueue? { get }

    /// 使用的 Alamofire Session（可用于注入自定义证书/缓存策略等）。
    static var session: HttpSession { get }

    /// 插件列表：如网络日志插件、授权插件等。
    static var plugins: [PluginType] { get }

    /// rxswift拦截器
    static var callAdapter: RxCallAdapter? { get }

    /// 是否开启请求去重（inflight request tracking）。
    static var trackInflights: Bool { get }
}

/// 不要和其他业务queue复用,避免相互影响 超时时间和排队问题
let networkCallbackQueue = DispatchQueue(label: "com.xxf.network.callback.queue",
                                         qos: .utility,
                                         attributes: [.concurrent])
public extension RestApiService {
    // MARK: - 默认实现，可按需在枚举中覆盖

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
        return networkCallbackQueue
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

    /// 默认插件列表：为空，可在服务中自定义返回如 NetworkLoggerPlugin。
    static var plugins: [PluginType] {
        []
    }

    /// rxswift拦截器
    static var callAdapter: RxCallAdapter? { return nil }

    /// 默认请求去重设置：关闭（多个相同请求会并发）。
    static var trackInflights: Bool {
        false
    }

    // MARK: - Provider 构建方法

    /// 构建并返回一个 MoyaProvider，使用当前类型定义的静态配置。
    /// - Returns: MoyaProvider<Self>
    static func adaptClient() -> HttpMoyaProvider<Self> {
        return HttpMoyaProvider<Self>(
            callAdapter: callAdapter,
            endpointClosure: endpointClosure,
            requestClosure: requestClosure,
            stubClosure: stubClosure,
            callbackQueue: callbackQueue,
            session: session.proxy,
            plugins: plugins,
            trackInflights: trackInflights
        )
    }
}
