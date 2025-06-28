//
//  Interceptor.swift
//  xxf_ios
// 拦截器,方法命名风格参考moya PluginType
// 将插件概念转化成拦截器概念
//  Created by xxf on /6/2.
//

public protocol Interceptor: Sendable {
    /// 即将请求
    func willSend(request: Request) -> EventLoopFuture<Request>
    /// 已经收到,马上要返回到网络层了
    func didReceive(response: Response?, error: Error?, for request: Request) -> EventLoopFuture<Response>
}
