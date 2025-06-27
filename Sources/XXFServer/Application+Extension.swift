//
//  Application+Extension.swift
//  xxf_ios
//
//  Created by xxf on /6/2.
//
import Vapor

public extension Application {
    /// 注册一个 BaseApiController 类型的所有 API
    func register<C: BaseApiController>(_: C.Type) {
        C.registerAll(on: self)
    }
}
