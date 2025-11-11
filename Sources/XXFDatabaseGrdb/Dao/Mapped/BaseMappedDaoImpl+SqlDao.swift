//
//  BaseViewDaoImpl+SqlDao.swift
//  xxf_ios
//
//  Created by xxf on /6/4.
//
import XXFDatabase
import XXFFoundation

extension BaseMappedDaoImpl: XXFDatabase.ReadableSqlDao {
    public func executeQuery(sql: String, params: XXFDatabase.StatementParams? = []) throws -> [any XXFDatabase.BaseRow] {
        return try proxyDao.executeQuery(sql: sql, params: params)
    }

    public func executeQuery<T>(sql: String, params: XXFDatabase.StatementParams?, asType type: T.Type) throws -> [T] where T: XXFDatabase.BaseTable {
        return try proxyDao.executeQuery(sql: sql, params: params, asType: type)
    }
}
