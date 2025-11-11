//
//  Observable+Error.swift
//  xxf_ios
//  r
//  Created by xxf on 7/9.
//

import RxSwift

public extension ObservableType {
    /// 忽略错误，错误发生时流结束，后续不再发出任何元素，也不会触发 onError
    func ignoreError() -> Observable<Element> {
        return catchError { _ in
            // 这里可以做日志上报、吐司提示等
            Observable.empty()
        }
    }
}
