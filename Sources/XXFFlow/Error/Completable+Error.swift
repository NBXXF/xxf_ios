//
//  Completable+Error.swift
//  xxf_ios
//
//  Created by xxf on 7/9.
//

import RxSwift

public extension Completable {
    /// 吞掉所有错误，直接 complete
    func ignoreError() -> Completable {
        return catchError { _ in
            // 这里可以打印或上报 error
            Completable.empty()
        }
    }
}
