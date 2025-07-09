//
//  Maybe+Error.swift
//  xxf_ios
//
//  Created by xxf on 7/9.
//

public extension PrimitiveSequence where Trait == MaybeTrait {
    /// 忽略错误：出错时结束流且不触发 onError
    func ignoreError() -> PrimitiveSequence<MaybeTrait, Element> {
        return catchError { _ in
            // 这里可以 log(error)
            PrimitiveSequence<MaybeTrait, Element>.empty()
        }
    }
}
