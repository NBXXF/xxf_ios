//
//  BasePageInfoDTO.swift
//  xxf_ios
//
//  Created by xxf on 2025/6/4.
//

import Foundation

/// 分页模型
open class BasePageInfoDTO<T> {
    /// 当前页 从1开始
    public var pageNum: Int = 0
    /// 每页数量
    public var pageSize: Int
    /// 是否有下一页
    public var hasNextPage: Bool
    /// 总数量，可能为 nil（逻辑分页）
    public var total: Int?

    /// 当前页数据
    public var list: [T]

    public init(pageNum: Int, pageSize: Int, hasNextPage: Bool, total: Int? = nil, list: [T]) {
        self.pageNum = pageNum
        self.pageSize = pageSize
        self.hasNextPage = hasNextPage
        self.total = total
        self.list = list
    }
}
