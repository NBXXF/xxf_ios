//
//  ErrorCompletableProxy.swift
//  xxf_ios
//
//  Created by trl on 2025/5/27.
//

import RxSwift

public class ErrorCompletableProxy: PrimitiveSequenceType {
    public typealias Trait = CompletableTrait
    // Completable 没有 Element，Element 使用 Void
    public typealias Element = Never

    private let source: Completable
    private let errorHandler: ErrorHandler
    private let toastPosition: Int
    private let filter: (Error) -> Bool

    public init(source: Completable,
                errorHandler: ErrorHandler,
                toastPosition: Int,
                filter: @escaping (Error) -> Bool = { _ in true })
    {
        self.source = source
        self.errorHandler = errorHandler
        self.toastPosition = toastPosition
        self.filter = filter
    }

    public var primitiveSequence: PrimitiveSequence<CompletableTrait, Element> {
        return source.do(onError: { error in
            if self.filter(error) {
                self.errorHandler.handle(error: error, toastPosition: self.toastPosition)
            }
        })
    }
}
