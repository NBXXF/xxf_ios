//
//  Single+Create.swift
//  xxf_ios
//
//  Created by xxf on /5/26.
//

import RxSwift

public extension Single {
    /// 类似 RxJava 的 fromCallable：同步执行闭包并发出结果或错误
    static func fromCallable(_ callable: @escaping () throws -> Element) -> Single<Element> {
        return Single.create { single in
            do {
                let result = try callable()
                single(.success(result))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}

/// Single 本质上是一个泛型类型别名（typealias）
public extension PrimitiveSequence where Trait == SingleTrait, Element == Void {
    /// fromAction 返回 Single<Void>，执行无返回值同步代码后发出完成事件
    static func fromAction(_ action: @escaping () throws -> Void) -> Single<Void> {
        return Single.create { single in
            do {
                try action()
                single(.success(()))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}
