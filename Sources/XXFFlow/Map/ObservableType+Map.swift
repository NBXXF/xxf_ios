//
//  ObservableType+Map.swift
//  xxf_ios
//
//  Created by xxf on7/26.
//

import RxSwift

public extension ObservableType {
    /// 变换成空
    func mapVoid() -> Observable<Void> {
        return map { _ in
        }
    }
}
