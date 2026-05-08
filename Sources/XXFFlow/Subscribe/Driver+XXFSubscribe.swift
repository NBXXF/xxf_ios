//
//  Driver+XXFSubscribe.swift
//  xxf_ios
//
//  Created by xxf on 7/30.
//

import RxCocoa
import RxSwift

public extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy {
    @discardableResult
    func subscribe(onNext: @escaping (Element) -> Void) -> Disposable {
        return drive(onNext: onNext)
    }

    @discardableResult
    func subscribe(
        onNext: @escaping (Element) -> Void,
        onCompleted: (() -> Void)? = nil,
        onDisposed: (() -> Void)? = nil
    ) -> Disposable {
        // Driver 不支持 onError，所以不暴露 onError 回调
        let disposable = drive(onNext: onNext, onCompleted: onCompleted ?? {})
        if let onDisposed = onDisposed {
            return Disposables.create(disposable, Disposables.create(with: onDisposed))
        } else {
            return disposable
        }
    }
}
