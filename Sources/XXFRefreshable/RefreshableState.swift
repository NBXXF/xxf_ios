//
//  RefreshableState.swift
//  xxf_ios
//  管理刷新状态
//  Created by xxf on 11/14.
//

import XXFFlow

/**
 用法一:

 用法 RefreshableState
 state.rx.bind(to: scrollView)

 用法二：

 绑定下拉刷新 refreshState.isRefreshing .bind(to: scrollView.rx.refreshing)
 绑定上拉加载 refreshState.isLoadingMore .bind(to: scrollView.rx.loadingMore)
 */
public struct RefreshableState: @unchecked Sendable {
    public let isRefreshing: Obs<Bool>
    public let isLoadingMore: Obs<Bool>

    public init(isRefreshing: Bool = false, isLoadingMore: Bool = false) {
        self.isRefreshing = isRefreshing.obs
        self.isLoadingMore = isLoadingMore.obs
    }

    func beginRefreshing() {
        isRefreshing.state = true
    }

    func endRefreshing() {
        isRefreshing.state = false
    }

    func beginLoadingMore() {
        isLoadingMore.state = true
    }

    func endLoadingMore() {
        isLoadingMore.state = false
    }
}
