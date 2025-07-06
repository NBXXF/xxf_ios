//
//  Maybe+Subscribe.swift
//  xxf_ios
//  简化订阅
//  Created by xxf on 5/26.
//

import RxSwift

public extension PrimitiveSequence where Trait == MaybeTrait {
    /// 可用bindLifecycle 来绑定生命周期,这里忽略返回值
    @discardableResult
    func subscribe(
        _ onNext: @escaping (Element) -> Void
    ) -> Disposable {
        return subscribe(onSuccess: onNext)
    }

    /// 可用bindLifecycle 来绑定生命周期,这里忽略返回值
    @discardableResult
    func subscribe() -> Disposable {
        return subscribe { _ in
        }
    }
}
