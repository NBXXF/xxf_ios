//
//  RefreshableCompatible.swift
//  xxf_ios
//  下拉刷新,上拉加载,抽象层
//  Created by xxf on 11/13.
//

public protocol RefreshableCompatible {
    // MARK: 监听

    /// 下拉刷新监听
    /// - Parameter action: 刷新执行回掉
    func addRefresh(action: @escaping () -> Void)

    /// 上拉加载
    /// - Parameter action: 加载执行回调
    func addLoadMore(action: @escaping () -> Void)

    // MARK: 刷新

    /// 开始主动下拉刷新
    /// - Parameter trigger: 主动触发回调执行真正的逻辑
    func beginRefreshing(trigger: Bool)

    /// 结束下拉刷新
    func endRefreshing()

    // MARK: 加载

    /// 开始主动上拉加载
    /// - Parameter trigger: 主动触发回调执行真正的逻辑
    func beginLoadingMore(trigger: Bool)

    /// 结束上拉加载
    func endLoadingMore()

    // MARK: 状态

    /// 是否正在执行下拉刷新
    func isRefreshing() -> Bool

    /// 是否正在执行上拉加载
    func isLoadingMore() -> Bool
}
