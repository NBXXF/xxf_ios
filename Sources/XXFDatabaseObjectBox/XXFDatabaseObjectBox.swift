//
//  XXFDatabaseObjectBox.swift
//  xxf_ios
//  ObjectBox 作为 XXFDatabase 的另一个实现模块（NoSQL 对象数据库）
//  设计参考 XXFDatabaseGrdb：对外暴露 BaseDaoImpl/BaseRepositoryImpl 的 ObjectBox 版本，
//  业务侧自定义 Entity 通过 // objectbox: entity 注解 + 代码生成插件生成绑定代码。
//  Created by xxf on 4/25.
//

@_exported import ObjectBox
@_exported import XXFDatabase
