//
//  SuperMoyaProvider.swift
//  xxf_ios
//  继承 将publicCallbackQueue公开,官方默认是他的库内可见
//  Created by trl on 8/23.
//
import Foundation
import Moya

public final class HttpMoyaProvider<Target: TargetType>: MoyaProvider<Target> {
    public let publicCallbackQueue: DispatchQueue?
    public let callAdapter: RxCallAdapter?

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
}
