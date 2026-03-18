//
//  RefreshableState+Rx.swift
//  xxf_ios
//  将 RefreshableState 绑定到事件流里面去，等同于对应的事件流发生改变，就会修改 state
//  Created by xxf on 11/14.
//

import XXFFlow

// MARK: - 通用扩展 (跨平台)

public extension Obs where Element == RefreshableState {
    /// 开始刷新或加载更多
    func begin(isRefresh: Bool) {
        if isRefresh {
            // 开始刷新时，确保加载更多是 false
            self.state = state.copy(isRefreshing: true, isLoadingMore: false)
        } else {
            // 开始加载更多时，确保刷新是 false
            self.state = state.copy(isRefreshing: false, isLoadingMore: true)
        }
    }

    /// 结束刷新或加载更多
    func end(isRefresh: Bool) {
        if isRefresh {
            self.state = state.copy(isRefreshing: false)
        } else {
            self.state = state.copy(isLoadingMore: false)
        }
    }
}

public extension ObservableType {
    /// 绑定刷新状态机
    /// - Parameters:
    ///   - state: 状态机
    ///   - isRefresh: 区分下拉刷新还是上拉加载
    func bindRefreshableState(
        of refreshableState: Obs<RefreshableState>,
        isRefresh: Bool,
        ignoreRefresh: Bool = true
    ) -> Observable<Element> {
        return self.doOnSubscribe { [weak refreshableState] in
            if !ignoreRefresh {
                refreshableState?.begin(isRefresh: isRefresh)
            }
        }.doOnNext { [weak refreshableState] _ in
            refreshableState?.end(isRefresh: isRefresh)
        }
        .doOnFinal { [weak refreshableState] in
            refreshableState?.end(isRefresh: isRefresh)
        }
    }
}

public extension PrimitiveSequence where Trait == SingleTrait {
    /// 绑定刷新状态机
    /// - Parameters:
    ///   - state: 状态机
    ///   - isRefresh: 区分下拉刷新还是上拉加载
    func bindRefreshableState(
        of refreshableState: Obs<RefreshableState>,
        isRefresh: Bool,
        ignoreRefresh: Bool = true
    ) -> Single<Element> {
        return self.doOnSubscribe { [weak refreshableState] in
            if !ignoreRefresh {
                refreshableState?.begin(isRefresh: isRefresh)
            }
        }.doOnNext { [weak refreshableState] _ in
            refreshableState?.end(isRefresh: isRefresh)
        }
        .doOnFinal { [weak refreshableState] in
            refreshableState?.end(isRefresh: isRefresh)
        }
    }
}

public extension PrimitiveSequence where Trait == MaybeTrait {
    /// 绑定刷新状态机
    /// - Parameters:
    ///   - state: 状态机
    ///   - isRefresh: 区分下拉刷新还是上拉加载
    func bindRefreshableState(
        of refreshableState: Obs<RefreshableState>,
        isRefresh: Bool,
        ignoreRefresh: Bool = true
    ) -> Maybe<Element> {
        return self.doOnSubscribe { [weak refreshableState] in
            if !ignoreRefresh {
                refreshableState?.begin(isRefresh: isRefresh)
            }
        }.doOnNext { [weak refreshableState] _ in
            refreshableState?.end(isRefresh: isRefresh)
        }
        .doOnFinal { [weak refreshableState] in
            refreshableState?.end(isRefresh: isRefresh)
        }
    }
}
