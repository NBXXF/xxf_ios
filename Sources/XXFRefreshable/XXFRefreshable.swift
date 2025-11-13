//
//  XXFRefreshable.swift
//  xxf_ios
//  下拉刷新,上拉加载,抽象层
//  Created by xxf on 11/13.
//

import MJRefresh

public protocol XXFRefreshableCompatible {
    /// 下拉刷新监听
    /// - Parameter action: 刷新执行回掉
    func addRefresh(action: @escaping () -> Void)

    /// 上拉加载
    /// - Parameter action: 加载执行回调
    func addLoadMore(action: @escaping () -> Void)

    /// 结束下拉刷新
    func endRefreshing()

    /// 结束上拉加载
    func endLoadMoreing()

    /// 开始主动下拉刷新
    func beginRefreshing()

    /// 是否正在执行下拉刷新
    func isRefreshing() -> Bool

    /// 是否正在执行上拉加载
    func isLoadMoreing() -> Bool
}

extension UIScrollView: @preconcurrency XXFRefreshableCompatible {}

public extension XXFRefreshableCompatible where Self: UIScrollView {
    @MainActor
    func addRefresh(action: @escaping () -> Void) {
        mj_header = MJRefreshNormalHeader { [weak self] in
            guard self != nil else { return }
            action()
        }
    }

    @MainActor
    func addLoadMore(action: @escaping () -> Void) {
        mj_footer = MJRefreshAutoNormalFooter { [weak self] in
            guard self != nil else { return }
            action()
        }
    }

    @MainActor
    func endRefreshing() {
        mj_header?.endRefreshing()
    }

    @MainActor
    func endLoadMoreing() {
        mj_footer?.endRefreshing()
    }

    @MainActor
    func beginRefreshing() {
        mj_header?.beginRefreshing()
        mj_header?.executeRefreshingCallback()
    }

    @MainActor
    func isRefreshing() -> Bool {
        return mj_header?.isRefreshing ?? false
    }

    @MainActor
    func isLoadMoreing() -> Bool {
        return mj_footer?.isRefreshing ?? false
    }
}
