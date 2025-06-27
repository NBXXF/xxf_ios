//
//  BuiltinTable.swift
//  xxf_ios
//  基础模型约束
//  Created by xxf on /6/4.
//

/// 所有内置记录
public protocol BuiltinTable: Codable {
    /// 返回所有内置记录（通常是静态写死）
    static var builtinRecords: [Self] { get }
}
