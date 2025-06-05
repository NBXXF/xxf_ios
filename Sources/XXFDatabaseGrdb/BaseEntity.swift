//
//  BaseEntity.swift
//  xxf_ios
//  GRDB 实现的实体约束
//  Created by xxf on 2025/6/4.
//
import GRDB
import XXFDatabase

/// 通用的数据库模型协议，包含基本的 GRDB 功能协议
/// - BaseTable: 通用约束,不局限于GRDB框架
/// - PersistableRecord: 支持写入数据库
/// - PersistableRecord: 支持写入数据库
/// - TableRecord:     支持自动生成查询请求和表名
public protocol BaseEntity: BaseTable, PersistableRecord, FetchableRecord, TableRecord {}
