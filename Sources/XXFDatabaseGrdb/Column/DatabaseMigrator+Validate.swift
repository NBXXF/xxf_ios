//
//  DatabaseMigrator+Validate.swift
//  xxf_ios
//  自动校验列补齐
//  Created by xxf on 6/24.
//
import XXFDatabase

public extension DatabaseMigrator {
    /// 校验列是否缺席
    mutating func validateTableSchema<E: BaseEntity, C: BaseColumnCodingKey>(
        for _: E.Type = E.self,
        columns _: C.Type = C.self
    ) {
        let databaseTableName = E.databaseTableName
        registerMigration("validateTableSchema_\(databaseTableName)") { db in
            let expectedColumns = Set(C.allColumns.map(\.name))
            let existingColumns = try Set(db.columns(in: databaseTableName).map(\.name))

            let missingColumns = expectedColumns.subtracting(existingColumns)
            let extraColumns = existingColumns.subtracting(expectedColumns)

            guard missingColumns.isEmpty, extraColumns.isEmpty else {
                var errorMessage = "表结构验证失败:"
                if !missingColumns.isEmpty {
                    errorMessage += "\n缺失列: \(missingColumns.joined(separator: ", "))"
                }
                if !extraColumns.isEmpty {
                    errorMessage += "\n多余列: \(extraColumns.joined(separator: ", "))"
                }
                throw DatabaseError(message: errorMessage)
            }
        }
    }
}
