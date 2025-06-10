//
//  BaseHttpResult.swift
//  xxf_ios
//  通用网络返回模型
//  Created by xxf on 2025/6/10.
//
public protocol BaseHttpResult: Codable {
    associatedtype DataType: Codable
    var code: Int { get set }
    var data: DataType? { get set }
    var msg: String? { get set }
    func isSuccess() -> Bool
}
