//
//  Array+Sql.swift
//  xxf_ios
//
//  Created by xxf on 6/11.
//

public extension Array where Element == String {
    /// 转换成 SQLite IN 列表，安全处理单引号和空数组
    /// SELECT * FROM table WHERE id IN ();  SQLite error: near ")": syntax error
    /// 返回-> "'abc','o''ne','x''y'"  用于in 查询,同时也解决sql 的999先制问题
    var sqlInValues: String {
        guard !isEmpty else { return "NULL" }

        var result = ""
        var first = true
        for id in self {
            if !first { result.append(",") }
            first = false
            let escapedId = id.replacingOccurrences(of: "'", with: "''")
            result.append("'\(escapedId)'")
        }
        return result
    }
}
