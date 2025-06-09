//
//  UIErrorTransformer.swift
//  xxf_ios
//
//  Created by xxf on /5/27.
//
import RxSwift

public class ErrorObservableProxy<Element>: ObservableType {
    typealias E = Element

    private let source: Observable<Element>
    private let errorHandler: ErrorHandler
    private let toastPosition: Int
    private let filter: (Error) -> Bool

    init(source: Observable<Element>,
         errorHandler: ErrorHandler,
         toastPosition: Int,
         filter: @escaping (Error) -> Bool = { _ in true })
    {
        self.source = source
        self.errorHandler = errorHandler
        self.toastPosition = toastPosition
        self.filter = filter
    }

    public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer: ObserverType, Observer.Element == Element {
        return source.doOnError { error in
            if self.filter(error) {
                self.errorHandler.handle(error: error, toastPosition: self.toastPosition)
            }
        }
        .subscribe(observer)
    }
}
