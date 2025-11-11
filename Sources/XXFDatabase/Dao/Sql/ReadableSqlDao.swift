//
//  SqlDao.swift
//  xxf_ios
//  只读
//  Created by xxf on /6/4.
//
import XXFDataSource

public protocol ReadableSqlDao: LocalDataSource {
    /// 查询
    /// - Parameters:
    ///   - sql: sql description
    ///   - params: params description,替换sql中的占位符(?),可直接使用数组或者字典参数,编译自动识别
    func executeQuery(sql: String, params: StatementParams?) throws -> [BaseRow]

    /// 支持查询sql 返回自定义模型
    /// - Parameters:
    ///   - type: 自定义模型的类型
    ///   - sql: sql
    ///   - params: sql占位符
    /// - Returns: 自定义模型
    func executeQuery<T: BaseTable>(
        sql: String,
        params: StatementParams?,
        asType type: T.Type,
    ) throws -> [T]
}
