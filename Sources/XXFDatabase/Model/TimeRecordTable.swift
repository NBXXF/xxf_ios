//
//  BaseTable.swift
//  xxf_ios
//  基础模型约束
//  Created by xxf on /6/4.
//
import Foundation

/// 记录操作行为时间
/// 约定公共字段
public protocol TimeRecordTable: Codable {
    /**
     * 创建时间
     */
    var createDate: Date { get set }

    /**
     * 更新时间
     */
    var updateDate: Date { get set }
}
