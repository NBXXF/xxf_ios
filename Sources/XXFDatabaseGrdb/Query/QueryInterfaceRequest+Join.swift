//
//  QueryInterfaceRequest+Join.swift
//  xxf_ios
//  简化连接查询
//  Created by xxf on 7/15.
//

import GRDB

// 用法                     SQL Join 类型     是否构建子模型    主表是否保留无子记录               典型用途
// .joining(required:)     INNER JOIN       ❌ 否            ❌ 否（只保留有匹配子记录的主表）   用子表字段做筛选、排序
// .including(required:)   INNER JOIN       ✅ 是            ❌ 否                          获取主表及子表数据（必须有子表）
// .joining(optional:)     LEFT JOIN        ❌ 否            ✅ 是（主表全保留）               用子表字段筛选/排序但不加载
// .including(optional:)   LEFT JOIN        ✅ 是            ✅ 是                          加载主表和可选子表（如 hasMany）

// 方法            场景                       生成 JOIN
// hasMany        一对多（A → [B]）           LEFT/INNER JOIN
// hasOne         一对一（A → B）             LEFT/INNER JOIN
// belongsTo      多对一（B → A）             LEFT/INNER JOIN
// through        多级关联（A → C via B）      多次 JOIN

/**
 // 1. 动态构造一个 to‑many 关联，不需要任何模型内部声明
 let dynamicAssociation = TagEntity.hasMany(
     FileTagEntity.self,
     key:TagEntity.CodingKeys.id.rawValue,      // 主表主键
     using:ForeignKey([FileTagEntity.CodingKeys.tagId.rawValue]) // 关联表外键
 )
 */
public extension QueryInterfaceRequest where RowDecoder: TableRecord {
    /// 通用连表方法，支持复合主键和复合外键，自动判断关联方向并生成合适的关联
    /// - Parameters:
    ///   - rightType: 右表模型类型
    ///   - foreignKeys: 右表外键字段（可多字段复合键）
    ///   - keys: 左表主键字段（可多字段复合键）
    ///   - joinType: 连接类型，默认左连接并预取（leftJoinPrefetch）
    /// - Returns: 新的 QueryInterfaceRequest 连接了关联表
    func joinTo<R: TableRecord>(
        _ rightType: R.Type,
        foreignKeys: [String],
        keys: [String],
        joinType: JoinType = .leftJoin
    ) -> Self {
        precondition(!foreignKeys.isEmpty, "foreignKeys is empty")
        precondition(!keys.isEmpty, "keys is empty")

        let rightColumns = R.allColumnNames
        // 判断 foreignKeys 是否都在右表中，若是，则表示主表 hasMany 右表
        let isForward = foreignKeys.allSatisfy { rightColumns.contains($0) }

        if isForward {
            // 主表 hasMany 右表
            // GRDB 的 hasMany API 只能接受单个主键字段，这里取第一个，实际业务可自行扩展
            let association = RowDecoder.hasMany(
                rightType,
                key: keys.first!,
                using: ForeignKey(foreignKeys, to: keys)
            )

            switch joinType {
                case .innerJoinPrefetch:
                    return including(required: association)
                case .innerJoin:
                    return joining(required: association)
                case .leftJoinPrefetch:
                    return including(optional: association)
                case .leftJoin:
                    return joining(optional: association)
            }

        } else {
            // 主表 belongsTo 右表（主表持有外键）
            // belongsTo API key 参数也只能单字段，这里取第一个
            let association = RowDecoder.belongsTo(
                rightType,
                key: foreignKeys.first!,
                using: ForeignKey(foreignKeys, to: keys)
            )

            switch joinType {
                case .innerJoinPrefetch:
                    return including(required: association)
                case .innerJoin:
                    return joining(required: association)
                case .leftJoinPrefetch:
                    return including(optional: association)
                case .leftJoin:
                    return joining(optional: association)
            }
        }
    }

    /// 简化版，单字段外键和主键
    func joinTo<R: TableRecord>(
        _ rightType: R.Type,
        foreignKey: String,
        key: String,
        joinType: JoinType = .leftJoinPrefetch
    ) -> Self {
        joinTo(rightType, foreignKeys: [foreignKey], keys: [key], joinType: joinType)
    }
}
