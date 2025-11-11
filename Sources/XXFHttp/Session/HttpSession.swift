//
//  HttpSession.swift
//  xxf_ios
//  添加日志记录,默认LoggerEventMonitor.shared
// 1. 自定义requestQueue 不然和rootQueue 一样在拦截器里面重试容易导致死锁
// 2. 我自定义了serializationQueue 可以提高解析速度
//  Created by xxf on 7/16.
//
import Alamofire
import Foundation
import Moya

/**
 rootQueue
 Session 的“底层根队列”，处理 URLSession 的 delegate 回调（数据接收、完成事件）。
 默认：串行队列。
 基本不要改，除非你非常清楚要干啥。

 requestQueue
 控制 RequestInterceptor (adapt / retry) 的调用环境。
 默认：串行队列。
 可以改成并发（前面说过）。

 serializationQueue
 专门用于 响应数据的解析/序列化（例如 responseJSON、responseDecodable）。
 默认：串行队列（防止多个请求同时序列化数据时打架）。
 你可以指定为并发队列，提升解析性能，但要注意避免数据竞争。
 */
public final class HttpSession: @unchecked Sendable {
    let proxy: Session

    public init(
        configuration: URLSessionConfiguration = URLSessionConfiguration.af.default,
        delegate: SessionDelegate = SessionDelegate(),
        rootQueue: DispatchQueue = DispatchQueue(label: "org.alamofire.session.rootQueue"),
        startRequestsImmediately: Bool = true,
        requestQueue: DispatchQueue? = DispatchQueue(
            label: "xxf.alamofire.session.requestQueue",
            attributes: .concurrent
        ),
        serializationQueue: DispatchQueue? = DispatchQueue(
            label: "xxf.alamofire.session.serializationQueue",
            attributes: .concurrent
        ),
        interceptor: (any RequestInterceptor)? = nil,
        serverTrustManager: ServerTrustManager? = nil,
        redirectHandler: (any RedirectHandler)? = nil,
        cachedResponseHandler: (any CachedResponseHandler)? = nil,
        eventMonitors: [any EventMonitor] = [AlamofireNotifications()]
    ) {
        // 1. 拷贝一份传入的 monitors
        var monitors = eventMonitors

        // 2. 如果其中没有 NetworkLoggerEventMonitor，就自动添加一个
        if !monitors.contains(where: { $0 is LoggerEventMonitor }) {
            monitors.append(LoggerEventMonitor.shared)
        }

        proxy = Session(
            configuration: configuration,
            delegate: delegate,
            rootQueue: rootQueue,
            startRequestsImmediately: startRequestsImmediately,
            requestQueue: requestQueue,
            serializationQueue: serializationQueue,
            interceptor: interceptor,
            serverTrustManager: serverTrustManager,
            redirectHandler: redirectHandler,
            cachedResponseHandler: cachedResponseHandler,
            eventMonitors: monitors
        )
    }
}
