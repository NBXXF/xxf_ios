//
//  Single+Create.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//

import Dispatch
import Foundation
import RxSwift

public extension Single {
    /// 类似 RxJava 的 fromCallable：同步执行闭包并发出结果或错误
    static func fromCallable(_ callable: @escaping () throws -> Element) -> Single<Element> {
        return Single<Element>.create { single in
            let disposable = BooleanDisposable()

            autoreleasepool {
                guard !disposable.isDisposed else { return }
                do {
                    let result = try callable()
                    if !disposable.isDisposed {
                        single(.success(result))
                    }
                } catch {
                    if !disposable.isDisposed {
                        single(.failure(error))
                    }
                }
            }

            return disposable
        }
    }
}

/// Single 本质上是一个泛型类型别名（typealias）
public extension PrimitiveSequence where Trait == SingleTrait, Element == Void {
    /// 类似 RxJava 的 fromAction：同步执行闭包并发出 success 或 error
    static func fromAction(_ action: @escaping () throws -> Void) -> Single<Void> {
        return Single<Void>.create { single in
            let disposable = BooleanDisposable()

            autoreleasepool {
                guard !disposable.isDisposed else { return }
                do {
                    try action()
                    if !disposable.isDisposed {
                        single(.success(()))
                    }
                } catch {
                    if !disposable.isDisposed {
                        single(.failure(error))
                    }
                }
            }

            return disposable
        }
    }
}
