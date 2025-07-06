//
//  Observable+Distinct.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//

import Dispatch
import RxSwift

public extension Observable {
    /// 按指定字段进行去重
    func distinctBy<T: Equatable>(by keySelector: @escaping (Element) -> T) -> Observable<Element> {
        return distinctUntilChanged { lhs, rhs in
            keySelector(lhs) == keySelector(rhs)
        }
    }
}

public extension Observable where Element: Equatable {
    /// 去除相邻重复元素（仅适用于 Element 遵循 Equatable）
    func distinct() -> Observable<Element> {
        return distinctUntilChanged()
    }
}

public extension Observable where Element: Hashable {
    func distinctByHash() -> Observable<Element> {
        return distinctUntilChanged { lhs, rhs in
            lhs.hashValue == rhs.hashValue
        }
    }
}
