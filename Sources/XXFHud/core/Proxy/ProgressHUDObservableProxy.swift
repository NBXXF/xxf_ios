//
//  ProgressHUDObservableProxy.swift
//  xxf_ios
//
//  Created by xxf on 5/27.
//

import RxSwift
import XXFFlow

public class ProgressHUDObservableProxy<Element>: ObservableType {
    typealias E = Element

    private let source: Observable<Element>
    private let progressHudHandler: ProgressHudHandler
    private let loadingNotice: String?
    private let successNotice: String?
    private let errorNotice: String?

    init(source: Observable<Element>,
         progressHudHandler: ProgressHudHandler,
         loadingNotice: String? = nil,
         successNotice: String? = nil,
         errorNotice: String? = nil)
    {
        self.source = source
        self.progressHudHandler = progressHudHandler
        self.loadingNotice = loadingNotice
        self.successNotice = successNotice
        self.errorNotice = errorNotice
    }

    public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer: ObserverType, Observer.Element == Element {
        source.doOnSubscribe {
            self.progressHudHandler.onSubscribe(loadingNotice: self.loadingNotice)
        }.doOnNext { value in
            self.progressHudHandler.onNext(value, successNotice: self.successNotice)
        }
        .doOnError { error in
            self.progressHudHandler.onError(error, errorNotice: self.errorNotice)
        }
        .doOnDispose {
            self.progressHudHandler.onDispose()
        }
        .subscribe(observer)
    }
}
