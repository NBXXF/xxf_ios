//
//  ErrorSingleProxy.swift
//  xxf_ios
//
//  Created by xxf on 5/27.
//

import RxSwift

public class ErrorSingleProxy<Element> {
    private let source: Single<Element>
    private let errorHandler: ErrorHandler
    private let toastPosition: Int
    private let filter: (Error) -> Bool

    init(source: Single<Element>,
         errorHandler: ErrorHandler,
         toastPosition: Int,
         filter: @escaping (Error) -> Bool = { _ in true })
    {
        self.source = source
        self.errorHandler = errorHandler
        self.toastPosition = toastPosition
        self.filter = filter
    }

    public func asSingle() -> Single<Element> {
        return source.doOnError { error in
            if self.filter(error) {
                self.errorHandler.handle(error: error, toastPosition: self.toastPosition)
            }
        }
    }
}
