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
 用法一:

 用法 RefreshableState
 public let refreshableState= RefreshableState().obs
 refreshableState .bind(to: scrollView.rx.refreshableState)

 用法二：
 public let isRefreshing: Bool = false.obs
 绑定下拉刷新 isRefreshing .bind(to: scrollView.rx.refreshing)
 public let isLoadingMore: Bool = false.obs
 绑定上拉加载 isLoadingMore .bind(to: scrollView.rx.loadingMore)
 */
public extension Reactive where Base: UIScrollView {
    var refreshing: Binder<Bool> {
        return Binder(base) { [weak base] _, isShow in
            guard let scrollView = base else { return }
            Task { @MainActor in
                if isShow {
                    scrollView.endLoadingMore() // 先结束加载更多
                    scrollView.beginRefreshing(trigger: false)
                } else {
                    scrollView.endRefreshing()
                }
            }
        }
    }

    var loadingMore: Binder<Bool> {
        return Binder(base) { [weak base] _, isShow in
            guard let scrollView = base else { return }
            Task { @MainActor in
                if isShow {
                    scrollView.endRefreshing() // 先结束刷新
                    scrollView.beginLoadingMore(trigger: false)
                } else {
                    scrollView.endLoadingMore()
                }
            }
        }
    }

    /// 聚合下拉刷新和上拉加载
    var refreshableState: Binder<RefreshableState> {
        return Binder(base) { [weak base] _, state in
            guard let scrollView = base else { return }
            Task { @MainActor in
                // 同时处理刷新和加载状态
                if state.isRefreshing {
                    scrollView.endLoadingMore() // 先结束加载更多
                    scrollView.beginRefreshing(trigger: false)
                } else {
                    scrollView.endRefreshing()
                }

                if state.isLoadingMore {
                    scrollView.endRefreshing() // 先结束刷新
                    scrollView.beginLoadingMore(trigger: false)
                } else {
                    scrollView.endLoadingMore()
                }
            }
        }
    }
}
