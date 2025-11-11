//
//  EmptyCodable.swift
//  xxf_ios
//  用于忽略json对象解析
//  Created by xxf on 7/10.
//
import Foundation

public struct EmptyCodable: Codable {
    public init() {} // 明确告诉编译器：这里有个无参初始化器
}
