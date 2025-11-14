//
//  RefreshableState+Rx.swift
//  xxf_ios
//  将RefreshableState 绑定到事件流里面去,等同于对应的事件流发生改变,就会修改state
//  Created by xxf on 11/14.
//
import UIKit
import XXFFlow

public extension ObservableType {
    /// 绑定刷新状态机
    /// - Parameters:
    ///   - state: 状态机
    ///   - isRefresh: 区分下拉刷新还是上拉加载
    func bindRefreshableState(
        of state: RefreshableState,
        isRefresh: Bool
    ) -> Observable<Element> {
        return self.doOnSubscribe {
            if isRefresh {
                state.beginRefreshing()
            } else {
                state.beginLoadingMore()
            }
        }.doOnNext { _ in
            if isRefresh {
                state.endRefreshing()
            } else {
                state.endLoadingMore()
            }
        }
        .doOnFinal {
            if isRefresh {
                state.endRefreshing()
            } else {
                state.endLoadingMore()
            }
        }
    }
}

public extension PrimitiveSequence where Trait == SingleTrait {
    /// 绑定刷新状态机
    /// - Parameters:
    ///   - state: 状态机
    ///   - isRefresh: 区分下拉刷新还是上拉加载
    func bindRefreshableState(
        of state: RefreshableState,
        isRefresh: Bool
    ) -> Single<Element> {
        return self.doOnSubscribe {
            if isRefresh {
                state.beginRefreshing()
            } else {
                state.beginLoadingMore()
            }
        }.doOnNext { _ in
            if isRefresh {
                state.endRefreshing()
            } else {
                state.endLoadingMore()
            }
        }
        .doOnFinal {
            if isRefresh {
                state.endRefreshing()
            } else {
                state.endLoadingMore()
            }
        }
    }
}

public extension PrimitiveSequence where Trait == MaybeTrait {
    /// 绑定刷新状态机
    /// - Parameters:
    ///   - state: 状态机
    ///   - isRefresh: 区分下拉刷新还是上拉加载
    func bindRefreshableState(
        of state: RefreshableState,
        isRefresh: Bool
    ) -> Maybe<Element> {
        return self.doOnSubscribe {
            if isRefresh {
                state.beginRefreshing()
            } else {
                state.beginLoadingMore()
            }
        }.doOnNext { _ in
            if isRefresh {
                state.endRefreshing()
            } else {
                state.endLoadingMore()
            }
        }
        .doOnFinal {
            if isRefresh {
                state.endRefreshing()
            } else {
                state.endLoadingMore()
            }
        }
    }
}

/**
 用法
 state.rx.bind(to: scrollView)
 */
public extension Reactive where Base == RefreshableState {
    /// 绑定 RefreshableState 到 UIScrollView 的刷新/加载状态
    func bind(to scrollView: UIScrollView) -> Disposable {
        Observable.combineLatest(base.isRefreshing, base.isLoadingMore)
            .subscribe(onNext: { isRefreshing, isLoadingMore in
                // 绑定到 UIScrollView 的 Binder
                scrollView.rx.refreshing.onNext(isRefreshing)
                scrollView.rx.loadingMore.onNext(isLoadingMore)
            })
    }
}
