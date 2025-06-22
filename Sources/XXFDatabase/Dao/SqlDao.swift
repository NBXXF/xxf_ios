//
//  SqlDao.swift
//  xxf_ios
//
//  Created by xxf on /6/4.
//

public protocol SqlDao {
    /// 插入/更新/删除 sql, 无返回值
    /// - Parameters:
    ///   - sql: sql description
    ///   - params: params description,替换sql中的占位符(?),可直接使用数组或者字典参数,编译自动识别
    func executeUpdate(sql: String, params: StatementParams?) throws

    /// 查询
    /// - Parameters:
    ///   - sql: sql description
    ///   - params: params description,替换sql中的占位符(?),可直接使用数组或者字典参数,编译自动识别
    func executeQuery(sql: String, params: StatementParams?) throws -> [BaseRow]
}
