//
//  Refreshable+Rx.swift
//  xxf_ios
//
//  Created by xxf on 11/14.
//

import UIKit
import XXFFlow

/**
 【状态机控制 --> UI显示逻辑】

 用法一：
 public let refreshableState = RefreshableState().obs
 refreshableState.bind(to: scrollView.rx.refreshableState)

 用法二：
 public let isRefreshing = false.obs
 isRefreshing.bind(to: scrollView.rx.refreshing)

 public let isLoadingMore = false.obs
 isLoadingMore.bind(to: scrollView.rx.loadingMore)
 */

public extension Reactive where Base: UIScrollView {
    // MARK: - 下拉刷新

    var refreshing: Binder<Bool> {
        return Binder(base) { [weak base] _, isShow in
            guard let scrollView = base else { return }
            Task { @MainActor in
                if isShow {
                    // 避免冲突：先停止加载更多
                    if scrollView.isLoadingMore() {
                        scrollView.endLoadingMore()
                    }
                    // 避免重复 beginRefreshing
                    if !scrollView.isRefreshing() {
                        scrollView.beginRefreshing(trigger: false)
                    }
                } else {
                    if scrollView.isRefreshing() {
                        scrollView.endRefreshing()
                    }
                }
            }
        }
    }

    // MARK: - 上拉加载更多

    var loadingMore: Binder<Bool> {
        return Binder(base) { [weak base] _, isShow in
            guard let scrollView = base else { return }
            Task { @MainActor in
                if isShow {
                    // 避免冲突：先停止下拉刷新
                    if scrollView.isRefreshing() {
                        scrollView.endRefreshing()
                    }
                    // 避免重复 beginloadingmore
                    if !scrollView.isLoadingMore() {
                        scrollView.beginLoadingMore(trigger: false)
                    }
                } else {
                    if scrollView.isLoadingMore() {
                        scrollView.endLoadingMore()
                    }
                }
            }
        }
    }

    // MARK: - 聚合刷新状态（推荐写法）

    var refreshableState: Binder<RefreshableState> {
        return Binder(base) { [weak base] _, state in
            guard let scrollView = base else { return }
            Task { @MainActor in
                // --- 下拉刷新 ---
                if state.isRefreshing {
                    // 避免冲突：先停止加载更多
                    if scrollView.isLoadingMore() {
                        scrollView.endLoadingMore()
                    }
                    // 避免重复 beginRefreshing
                    if !scrollView.isRefreshing() {
                        scrollView.beginRefreshing(trigger: false)
                    }
                } else {
                    if scrollView.isRefreshing() {
                        scrollView.endRefreshing()
                    }
                }

                // --- 上拉加载 ---
                if state.isLoadingMore {
                    // 避免冲突：先停止下拉刷新
                    if scrollView.isRefreshing() {
                        scrollView.endRefreshing()
                    }
                    // 避免重复 beginloadingmore
                    if !scrollView.isLoadingMore() {
                        scrollView.beginLoadingMore(trigger: false)
                    }
                } else {
                    if scrollView.isLoadingMore() {
                        scrollView.endLoadingMore()
                    }
                }
            }
        }
    }
}
