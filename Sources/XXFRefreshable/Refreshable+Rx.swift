//
//  Refreshable+Rx.swift
//  xxf_ios
//
//  Created by xxf on 11/14.
//

import UIKit
import XXFFlow

/**
 用法一:

 用法 RefreshableState
 state.rx.bind(to: scrollView)

 用法二：

 绑定下拉刷新 refreshState.isRefreshing .bind(to: scrollView.rx.refreshing)
 绑定上拉加载 refreshState.isLoadingMore .bind(to: scrollView.rx.loadingMore)
 */
public extension Reactive where Base: UIScrollView {
    var refreshing: Binder<Bool> {
        return Binder(base) { scrollView, isShow in
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
        return Binder(base) { scrollView, isShow in
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
}
