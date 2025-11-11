//
//  SqlDao.swift
//  xxf_ios
//  可写的
//  Created by xxf on /6/4.
//
import XXFDataSource

public protocol WritableSqlDao: LocalDataSource {
    /// 插入/更新/删除 sql, 无返回值
    /// - Parameters:
    ///   - sql: sql description
    ///   - params: params description,替换sql中的占位符(?),可直接使用数组或者字典参数,编译自动识别
    func executeUpdate(sql: String, params: StatementParams?) throws

    /// 列单独插入或者更新（支持 Any 类型）
    /// - Parameters:
    ///   - conflictColumn: 冲突列，主键或者唯一索引
    ///   - conflictValue: 冲突列的值（Any 类型）
    ///   - columnsToUpdate: 更新或插入的列及对应值（Any? 类型）
    func executeUpsert(
        conflictColumn: String,
        conflictValue: Any,
        columnsToUpdate: [String: Any?]
    ) throws
}
