//
//  RestApiService.swift
//  xxf_ios
//  ApiService简化配置
//  Created by xxf on /6/9.
//

import Foundation
import Moya

/// API 服务协议：所有 API 枚举（如 UserApiService）应继承此协议。
/// 提供统一的 MoyaProvider 构建机制，并支持通过静态属性配置。
public protocol RestApiService: BaseApiService,CacheableApiService {
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

    /// 拦截器列表：如网络日志插件、授权插件等。
    static var interceptors: [Interceptor] { get }

    /// rxswift拦截器
    static var callAdapter: RxCallAdapter? { get }

    /// 是否开启请求去重（inflight request tracking）。
    static var trackInflights: Bool { get }

}
