//
//  SQLSpecificExpressible+Extension.swift
//  xxf_ios
//  查询相关
//  Created by xxf on 7/12.
//

import Foundation
import GRDB

/// 模糊匹配模式，用于控制 LIKE 查询的通配符位置
public enum LikeMatchMode {
    /// 全模糊匹配：`%keyword%`
    case contains
    /// 前缀匹配：`keyword%`
    case startsWith
    /// 后缀匹配：`%keyword`
    case endsWith
    /// 精确匹配：`keyword`
    case exact
}

public extension SQLSpecificExpressible {
    /// 安全的 SQL LIKE 查询，支持 ESCAPE、大小写控制和多种匹配模式
    /// 比自带的 like 更好用
    ///
    /// - Parameters:
    ///   - keyword:       要匹配的关键字，内部自动转义 `%`、`_` 和 `\`
    ///   - escape:        ESCAPE 子句使用的 SQL 表达式，默认 `"\\"`（传入 `nil` 则不使用 ESCAPE）
    ///   - caseSensitive: 是否区分大小写，默认 `true`（区分大小写）
    ///   - matchMode:     匹配模式，默认全模糊（%keyword%）
    /// - Returns: 构建好的 `SQLExpression`
    func contains(
        _ keyword: String,
        escape: (any SQLExpressible)? = "\\",
        caseSensitive: Bool = true,
        matchMode: LikeMatchMode = .contains
    ) -> SQLExpression {
        // 1. 根据 escape 是否为 nil 决定 pattern 和 escapeExpr
        let (pattern, escapeExpr): (String, (any SQLExpressible)?) = {
            guard let escExpr = escape else {
                // 不使用 ESCAPE：直接按通配符拼接，不做转义
                let raw = makeLikePattern(from: keyword, escapeChar: "", matchMode: matchMode)
                return (raw, nil)
            }
            // 使用 ESCAPE：先把 escExpr 转为 String，用于转义逻辑
            let escChar = "\(escExpr)"
            let raw = makeLikePattern(from: keyword, escapeChar: escChar, matchMode: matchMode)
            return (raw, escExpr)
        }()

        // 2. 将 self 转为 SQLExpression，并可选添加 COLLATE NOCASE
        let columnExpr: SQLExpression = {
            let base = self.sqlExpression
            return caseSensitive
                ? base // 区分大小写：不加 COLLATE
                : base.collating(.nocase) // 不区分大小写：加 NOCASE
        }()

        // 3. 调用对应的 like API
        if let esc = escapeExpr {
            return columnExpr.like(pattern, escape: esc)
        } else {
            return columnExpr.like(pattern)
        }
    }

    // MARK: - Helper

    /// 构造 LIKE 模式字符串，根据模式类型和 escapeChar 自动加 `%` 和转义
    private func makeLikePattern(
        from keyword: String,
        escapeChar: String,
        matchMode: LikeMatchMode
    ) -> String {
        guard !keyword.isEmpty else {
            // 空关键字时，用 '%%' 匹配所有非 NULL 行
            return "%%"
        }
        let escaped = keyword.sqlEscapedForLike(escapeChar: escapeChar)
        switch matchMode {
        case .contains: return "%\(escaped)%"
        case .startsWith: return "\(escaped)%"
        case .endsWith: return "%\(escaped)"
        case .exact: return escaped
        }
    }

    /// 安全的多关键词 SQL LIKE 查询（or 逻辑）
    /// 支持 ESCAPE、大小写控制和多种匹配模式
    ///
    /// - Parameters:
    ///   - keywords:      要匹配的关键词数组，每个关键词内部自动转义 `%`、`_` 和 `\`
    ///   - escape:        ESCAPE 子句使用的 SQL 表达式，默认 `"\\"`（传入 `nil` 则不使用 ESCAPE）
    ///   - caseSensitive: 是否区分大小写，默认 `true`（区分大小写）
    ///   - matchMode:     匹配模式，默认全模糊（%keyword%）
    /// - Returns: 构建好的 `SQLExpression`
    func contains(
        anyOf keywords: [String],
        escape: (any SQLExpressible)? = "\\",
        caseSensitive: Bool = true,
        matchMode: LikeMatchMode = .contains
    ) -> SQLExpression {
        guard !keywords.isEmpty else {
            // 空关键词数组：返回 true 表达式（匹配所有行）
            return true.databaseValue.sqlExpression
        }

        // 为每个关键词创建表达式并用 AND 连接
        return keywords.map { keyword in
            self.contains(
                keyword,
                escape: escape,
                caseSensitive: caseSensitive,
                matchMode: matchMode
            )
        }.joined(operator: .or)
    }
}
