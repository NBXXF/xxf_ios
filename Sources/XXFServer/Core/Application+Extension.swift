//
//  Application+Extension.swift
//  xxf_ios
//  管理路由注册和分发
//  Created by xxf on /6/2.
//

public extension Application {
    /// 注册一个 RestApiController 类型的所有 API
    func register<C: RestApiController>(_: C.Type, dispatcher: ControllerDispatcher? = nil) {
        ControllerRegister.register(on: self, type: C.self, dispatcher: dispatcher)
    }
}
