//
//  ObsWrapper.swift
//  xxf_ios
//
//  Created by xxf on 4/29.
//

import RxSwift

/// 创建一个 `Obs<T>`（即 `BehaviorRelay<T>`），可选地挂一个值变化副作用。
///
/// 用 `.do(onNext:)` 表达"这是旁路副作用（持久化 / 日志 / 埋点），不是主消费路径"。
/// 订阅随 relay 自身的生命周期自动结束——relay 被释放时，内部 observer
/// 一并被清理。因此无需对外返回 `Disposable`。
///
/// - Important: `onChange` 捕获外部对象（尤其是 `self`）时请使用 `[weak self]`，
///   否则会和 relay 形成循环引用。
///
/// - Parameters:
///   - initial: 初始值，订阅方读到的第一帧
///   - onChange: 值变化副作用，已 `skip(1)` 跳过初始值本身；默认 `nil` 表示不挂副作用
/// - Returns: 可读可写的 `Obs<T>`
public func makeObs<T>(
    initial: T,
    onChange: @escaping ((T) -> Void),
    disposeBag: DisposeBag
) -> Obs<T> {
    let relay = Obs<T>(value: initial)
    _ = relay.skip(1)
        .subscribe(onNext: onChange)
        .disposed(by: disposeBag)
    return relay
}
