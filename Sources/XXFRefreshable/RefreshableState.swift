//
//  RefreshableState.swift
//  xxf_ios
//  管理刷新状态
//  Created by xxf on 11/14.
//

import XXFFlow

/**
 【状态机控制 --> UI显示逻辑】

 用法 RefreshableState
 public let refreshableState = RefreshableState().obs
 refreshableState .bind(to: scrollView.rx.refreshableState)
 */
public struct RefreshableState: @unchecked Sendable, ObsConvertible, Hashable, Equatable {
    public let isRefreshing: Bool
    public let isLoadingMore: Bool

    public init(isRefreshing: Bool = false, isLoadingMore: Bool = false) {
        self.isRefreshing = isRefreshing
        self.isLoadingMore = isLoadingMore
    }

    public func copy(
        isRefreshing: Bool? = nil,
        isLoadingMore: Bool? = nil
    ) -> RefreshableState {
        return RefreshableState(
            isRefreshing: isRefreshing ?? self.isRefreshing,
            isLoadingMore: isLoadingMore ?? self.isLoadingMore
        )
    }
}
