//
//  BaseRow.swift
//  xxf_ios
//  行结果定义
//  Created by xxf on 6/4.
//

public protocol BaseRow {
    /// 获取列值
    func value<T>(forColumn column: String) -> T?

    /// 支持下标语法
    subscript<T>(_: String) -> T? { get }
}
