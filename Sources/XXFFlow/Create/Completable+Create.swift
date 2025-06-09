//
//  Completable+Create.swift
//  xxf_ios
//
//  Created by xxf on /5/26.
//

import RxSwift

public extension Completable {
    /// fromAction 返回 Completable，执行无返回值同步代码后发出完成事件
    static func fromAction(_ action: @escaping () throws -> Void) -> Completable {
        return Completable.create { completable in
            do {
                try action()
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }

    /// fromCallable 返回 Completable，执行有返回值代码，但忽略返回值，仅关心成功或错误
    static func fromCallable<T>(_ callable: @escaping () throws -> T) -> Completable {
        return Completable.create { completable in
            do {
                _ = try callable()
                completable(.completed)
            } catch {
                completable(.error(error))
            }
            return Disposables.create()
        }
    }
}
