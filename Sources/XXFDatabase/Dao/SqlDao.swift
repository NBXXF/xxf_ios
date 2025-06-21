//
//  SqlDao.swift
//  xxf_ios
//
//  Created by xxf on /6/4.
//

public protocol SqlDao {
    /// 插入/更新/删除 sql, 无返回值
    func executeUpdate(sql: String) throws

    /// 查询
    func executeQuery(sql: String) throws -> [BaseRow]
}
