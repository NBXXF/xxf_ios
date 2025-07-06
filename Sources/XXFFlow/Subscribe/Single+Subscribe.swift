//  Single+Subscribe.swift
//  xxf_ios
//  简化订阅
//  Created by xxf on 5/26.
//

import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {
    /// 可用bindLifecycle 来绑定生命周期,这里忽略返回值
    /// 解决一致性的问题 onSuccess->onNext
    @discardableResult
    func subscribeNext(
        onNext: @escaping (Element) -> Void,
        onFailure: ((Swift.Error) -> Void)? = nil,
        onDisposed: (() -> Void)? = nil
    ) -> Disposable {
        return subscribe(onSuccess: onNext, onFailure: onFailure, onDisposed: onDisposed)
    }

    /// 可用bindLifecycle 来绑定生命周期,这里忽略返回值
    @discardableResult
    func subscribe() -> Disposable {
        return subscribe(onSuccess: nil)
    }
}
