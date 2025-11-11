//
//  ErrorHandler.swift
//  xxf_ios
//
//  Created by xxf on 5/27.
//

public protocol ErrorHandler {
    /// 处理异常
    func handle(error: Error, toastPosition: Int)

    /// 转换异常
    func convert(error: Error) -> String
}
