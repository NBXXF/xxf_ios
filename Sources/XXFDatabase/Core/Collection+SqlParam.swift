//
//  Collection+SqlParam.swift
//  xxf_ios
//
//  Created by xxf on 8/9.
//
import Algorithms

public extension Collection {
    /// 返回二维数组
    /// 持的最大参数数量,如sqlite 最多只支持999,尤其是在in 查询的场景下面
    func chunkedSqlArray() -> [[Element]] {
        /// sqlite 最多支持999,除去一张表最多199段吧
        return chunks(ofCount: 999 - 199).map(Array.init)
    }
}
