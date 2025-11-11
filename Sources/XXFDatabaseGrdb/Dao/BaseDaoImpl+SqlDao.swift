//
//  BaseDaoImpl+SqlDao.swift
//  xxf_ios
//
//  Created by xxf on /6/4.
//
import XXFDatabase
import XXFFoundation

extension BaseDaoImpl: SqlDao {
    // MARK: 支持sql

    public func executeUpdate(sql: String, params: XXFDatabase.StatementParams? = []) throws {
        try proxy.write { db in
            try db.execute(sql: sql, arguments: (params?.toStatementArguments() ?? StatementArguments()))
        }
    }

    /// 列单独插入或者更新
    /// - Parameters:
    ///   - conflictColumn:冲突列, 主键或者唯一索引
    ///   - conflictValue: 冲突列的值
    ///   - columnsToUpdate: 更新或者插入的列
    public func executeUpsert(conflictColumn: String, conflictValue: Any, columnsToUpdate: [String: Any?]) throws {
        try executeUpsert(conflictColumn: conflictColumn,
                          conflictValue: conflictValue as! DatabaseValueConvertible,
                          columnsToUpdate: columnsToUpdate.mapValues { item in
                              if item == nil {
                                  return nil
                              }
                              return (item as! DatabaseValueConvertible)
                          })
    }

    private func executeUpsert(conflictColumn: String,
                               conflictValue: DatabaseValueConvertible,
                               columnsToUpdate: [String: DatabaseValueConvertible?]) throws
    {
        guard !columnsToUpdate.isEmpty else { return }

        // 排除冲突列，保证顺序一致
        let columnKeys = columnsToUpdate.keys.filter { $0 != conflictColumn }
        guard !columnKeys.isEmpty else { return }

        let tableName = Self.Entity.databaseTableName

        let insertColumns = [conflictColumn] + columnKeys
        let placeholders = Array(repeating: "?", count: insertColumns.count).joined(separator: ", ")
        let insertValues: [DatabaseValueConvertible?] = [conflictValue] + columnKeys.map { columnsToUpdate[$0]! }

        let updateClause = columnKeys.map { "\($0) = excluded.\($0)" }.joined(separator: ", ")

        /**
         INSERT INTO table_name (col1, col2, col3)
         VALUES (?, ?, ?)
         ON CONFLICT(conflict_col) DO UPDATE SET
             col2 = excluded.col2,
             col3 = excluded.col3
         */
        let sql = """
        INSERT INTO \(tableName) (\(insertColumns.joined(separator: ", ")))
        VALUES (\(placeholders))
        ON CONFLICT(\(conflictColumn)) DO UPDATE SET \(updateClause)
        """

        try proxy.write { db in
            try db.execute(sql: sql, arguments: StatementArguments(insertValues))
        }
    }

    public func executeQuery(sql: String, params: XXFDatabase.StatementParams? = []) throws -> [any XXFDatabase.BaseRow] {
        let rows = try proxy.read { db in
            try Row.fetchAll(db, sql: sql, arguments: (params?.toStatementArguments() ?? StatementArguments()))
        }
        return rows
    }

    public func executeQuery<T>(sql: String, params: XXFDatabase.StatementParams?, asType type: T.Type) throws -> [T] where T: XXFDatabase.BaseTable {
        guard let baseEntityType = type as? (any BaseEntity.Type) else {
            throw DatabaseParamError(underlyingErrorMsg: entityTypeError)
        }
        return try proxy.read { db in
            try baseEntityType.fetchAll(
                db,
                sql: sql,
                arguments: params?.toStatementArguments() ?? StatementArguments()
            ) as! [T]
        }
    }
}
