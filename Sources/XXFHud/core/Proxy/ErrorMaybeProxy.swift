//
//  ErrorMaybeProxy.swift
//  xxf_ios
//
//  Created by xxf on /5/27.
//

import RxSwift

public class ErrorMaybeProxy<Element>: PrimitiveSequenceType {
    public typealias Trait = MaybeTrait

    private let source: Maybe<Element>
    private let errorHandler: ErrorHandler
    private let toastPosition: Int
    private let filter: (Error) -> Bool

    public init(source: Maybe<Element>,
                errorHandler: ErrorHandler,
                toastPosition: Int,
                filter: @escaping (Error) -> Bool = { _ in true })
    {
        self.source = source
        self.errorHandler = errorHandler
        self.toastPosition = toastPosition
        self.filter = filter
    }

    public var primitiveSequence: PrimitiveSequence<MaybeTrait, Element> {
        return source.doOnError { error in
            if self.filter(error) {
                self.errorHandler.handle(error: error, toastPosition: self.toastPosition)
            }
        }
    }
}
