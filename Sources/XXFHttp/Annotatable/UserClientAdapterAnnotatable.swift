//
//  BaseApiService.swift
//  xxf_ios
//  可高度自定义配置client
//  Created by xxf on /6/8.
//
import Foundation
import Moya

public protocol UserClientAdapterAnnotatable: TargetType {
    static func adaptClient() -> MoyaProvider<Self>
}

public extension UserClientAdapterAnnotatable {
    static func adaptClient() -> MoyaProvider<Self> {
        MoyaProvider<Self>()
    }
}
