//
//  BaseTable.swift
//  xxf_ios
//  基础模型约束
//  Created by xxf on /6/4.
//
import Foundation

/// 记录操作行为时间
/// 约定公共字段,gpt主流数据库推荐created_at/updated_at
public protocol TimeRecordTable: Codable {
    /**
     * 创建时间
     */
    var createdAt: Date { get set }

    /**
     * 更新时间
     */
    var updatedAt: Date { get set }
}
