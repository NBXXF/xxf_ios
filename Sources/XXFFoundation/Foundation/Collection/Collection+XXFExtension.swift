//
//  Collection+XXFExtension.swift
//  xxf_ios
//
//  Created by xxf on 8/7.
//
import Algorithms

public extension Collection {
    /// 返回二维数组，每个子数组最多 count 个元素
    /// - Parameter count: 每块的最大元素数量，小于等于 0 时返回空数组
    func chunkedArray(ofCount count: Int) -> [[Element]] {
        guard count > 0 else { return [] }
        return chunks(ofCount: count).map(Array.init)
    }

    // 不为空
    var isNotEmpty: Bool { !isEmpty }
}
