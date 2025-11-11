//
//  Error+Extension.swift
//  xxf_ios
//
//  Created by xxf on 7/9.
//
import Foundation

public extension Error {
    /// 将 Swift Error 转成 NSError，方便访问 domain/code/userInfo
    var nsError: NSError? { self as NSError? }
}
