//
//  RefreshableState+Rx.swift
//  xxf_ios
//  将RefreshableState 绑定到事件流里面去,等同于对应的事件流发生改变,就会修改state
//  Created by xxf on 11/14.
//
import UIKit
import XXFFlow

/**
 【业务加载更新 --> 状态机的值】
 */
public extension Obs where Element == RefreshableState {
    /// 开始刷新或加载更多
    func begin(isRefresh: Bool) {
        if isRefresh {
            self.state = state.copy(isRefreshing: true)
        } else {
            self.state = state.copy(isLoadingMore: true)
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
        isRefresh: Bool
    ) -> Observable<Element> {
        return self.doOnSubscribe { [weak refreshableState] in
            refreshableState?.begin(isRefresh: isRefresh)
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
        isRefresh: Bool
    ) -> Single<Element> {
        return self.doOnSubscribe { [weak refreshableState] in
            refreshableState?.begin(isRefresh: isRefresh)
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
        isRefresh: Bool
    ) -> Maybe<Element> {
        return self.doOnSubscribe { [weak refreshableState] in
            refreshableState?.begin(isRefresh: isRefresh)
        }.doOnNext { [weak refreshableState] _ in
            refreshableState?.end(isRefresh: isRefresh)
        }
        .doOnFinal { [weak refreshableState] in
            refreshableState?.end(isRefresh: isRefresh)
        }
    }
}
