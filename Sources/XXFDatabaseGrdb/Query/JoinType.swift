//
//  JoinType.swift
//  xxf_ios
//  连接查询类型
//  Created by xxf on 7/15.
//
/**
 综合起来的区别
 枚举值                            连接类型             是否预加载子模型               关联是否必需（required/optional）     备注
 innerJoin                      INNER JOIN         不加载                                     必需（required）                                只返回有子模型的主模型数据
 innerJoinPrefetch           INNER JOIN       预加载                                    必需（required）                                 只返回有子模型，且预加载子模型
 leftJoin                         LEFT JOIN           不加载                                      可选（optional）                                 返回所有主模型数据，子模型数据不加载
 leftJoinPrefetch           LEFT JOIN            预加载                                     可选（optional）                                 返回所有主模型数据，预加载子模型

 总结
 INNER JOIN 是强制要求子模型存在，否则该主模型不出现在结果中。

 LEFT JOIN 是允许子模型不存在的，主模型仍返回，子模型字段为 null。

 Prefetch 选项决定是否在查询时自动加载子模型对象，方便后续使用。

 不 Prefetch 就是查询结果中只包含主模型数据，或者需要自己额外去加载子模型。
 */

public enum JoinType {
    case innerJoin // INNER JOIN，不加载子模型（joining required）
    case innerJoinPrefetch // INNER JOIN，加载子模型（including required）
    case leftJoin // LEFT JOIN，不加载子模型（joining optional）
    case leftJoinPrefetch // LEFT JOIN，加载子模型（including optional）
}
