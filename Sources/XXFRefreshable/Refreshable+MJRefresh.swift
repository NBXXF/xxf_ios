//
//  Refreshable+MJRefresh.swift
//  xxf_ios
//  下拉刷新,上拉加载,抽象层
//  Created by xxf on 11/13.
//

import MJRefresh

extension UIScrollView: @preconcurrency RefreshableCompatible {}

public extension RefreshableCompatible where Self: UIScrollView {
    // MARK: 监听

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

    // MARK: 刷新

    @MainActor
    func beginRefreshing(trigger: Bool) {
        mj_header?.beginRefreshing()
        mj_header?.executeRefreshingCallback()
    }

    @MainActor
    func endRefreshing() {
        mj_header?.endRefreshing()
    }

    // MARK: 加载

    @MainActor
    func beginLoadingMore(trigger: Bool) {
        mj_footer?.beginRefreshing()
        mj_footer?.executeRefreshingCallback()
    }

    @MainActor
    func endLoadingMore() {
        mj_footer?.endRefreshing()
    }

    // MARK: 状态

    @MainActor
    func isRefreshing() -> Bool {
        return mj_header?.isRefreshing ?? false
    }

    @MainActor
    func isLoadingMore() -> Bool {
        return mj_footer?.isRefreshing ?? false
    }
}
