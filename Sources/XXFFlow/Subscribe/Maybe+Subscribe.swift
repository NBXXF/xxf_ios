//
//  Maybe+Subscribe.swift
//  xxf_ios
//  简化订阅
//  Created by xxf on 5/26.
//

import RxSwift

public extension PrimitiveSequence where Trait == MaybeTrait {
    /// 可用bindLifecycle 来绑定生命周期,这里忽略返回值
    /// 解决一致性的问题 onSuccess->onNext
    @discardableResult
    func subscribe(
        onNext: @escaping (Element) -> Void,
        onError: ((Swift.Error) -> Void)? = nil,
        onCompleted: (() -> Void)? = nil,
        onDisposed: (() -> Void)? = nil
    ) -> Disposable {
        return subscribe(onSuccess: onNext, onError: onError, onCompleted: onCompleted, onDisposed: onDisposed)
    }

    /// 可用bindLifecycle 来绑定生命周期,这里忽略返回值
    @discardableResult
    func subscribe() -> Disposable {
        return subscribe { _ in
        }
    }
}
