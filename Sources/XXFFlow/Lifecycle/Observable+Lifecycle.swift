//
//  Observable+Create.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/26.
//
import ObjectiveC
import RxCocoa
import RxSwift

public extension ObservableType {
    /// 绑定生命周期
    func bindUntilDeallocated<T: NSObject>(of object: T) -> Observable<Element> {
        return take(until: object.rx.deallocated)
    }
}
