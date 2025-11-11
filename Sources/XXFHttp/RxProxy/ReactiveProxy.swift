//
//  ReactiveProxy.swift
//  xxf_ios
//  增加rx代理,主要作用便是拦截
//  Created by xxf on 8/23.
//
import Foundation
import Moya
import RxSwift

public final class ReactiveProxy<Base: MoyaProviderType> {
    let base: Base

    init(_ base: Base) {
        self.base = base
    }
}
