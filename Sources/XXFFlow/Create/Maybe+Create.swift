//
//  Maybe+Create.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//

import RxSwift

public extension Maybe {
    /// fromCallable 返回 Maybe<Element>，同步执行闭包并发出结果、完成或错误
    static func fromCallable(_ callable: @escaping () throws -> Element?) -> Maybe<Element> {
        return Maybe.create { maybe in
            do {
                if let result = try callable() {
                    maybe(.success(result))
                } else {
                    maybe(.completed)
                }
            } catch {
                maybe(.error(error))
            }
            return Disposables.create()
        }
    }
}

public extension Maybe where Element == Void {
    /// fromAction 返回 Maybe<Void>，执行无返回值同步代码后发出完成事件
    static func fromAction(_ action: @escaping () throws -> Void) -> Maybe<Void> {
        return Maybe.create { maybe in
            do {
                try action()
                maybe(.success(()))
            } catch {
                maybe(.error(error))
            }
            return Disposables.create()
        }
    }
}
