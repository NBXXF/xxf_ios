//
//  StatementArguments+Params.swift
//  xxf_ios
//
//  Created by xxf on 6/04.
//
import Foundation
import XXFDatabase

extension StatementParams {
    // MARK: - 转成 GRDB 要求的 StatementArguments

    /// 把 StatementParams 转成 GRDB 的 StatementArguments
    @inlinable
    @inline(__always)
    func toStatementArguments() throws -> StatementArguments {
        switch self {
        case let .array(arr):
            // [Any?] -> [Any], 把 nil 替换成 NSNull()
            let rawArray: [Any] = arr.map { $0 ?? NSNull() }
            guard let sa = StatementArguments(rawArray) else {
                throw
                    DatabaseParamError(underlyingErrorMsg: "Invalid array params: \(arr)")
            }
            return sa

        case let .dict(d):
            // [String: Any?] -> [String: Any], 把 nil 替换成 NSNull()
            let rawDict: [String: Any] = Dictionary(
                uniqueKeysWithValues: d.map { key, value in (key, value ?? NSNull()) }
            )
            guard let sa = StatementArguments(rawDict) else {
                throw DatabaseParamError(underlyingErrorMsg: "Invalid dict params: \(d)")
            }
            return sa
        }
    }
}
