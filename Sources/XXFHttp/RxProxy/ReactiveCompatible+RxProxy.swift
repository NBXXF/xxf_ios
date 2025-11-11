//
//  ReactiveProxy.swift
//  xxf_ios
//  增加rx代理,主要作用便是拦截
//  Created by xxf on 8/23.
//
import Moya
import RxSwift

public extension ReactiveCompatible where Self: MoyaProviderType {
    /// ReactiveProxy 代理
    var rxProxy: ReactiveProxy<Self> {
        return ReactiveProxy(self)
    }
}
