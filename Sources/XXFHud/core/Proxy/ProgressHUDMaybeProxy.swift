//
//  ProgressHUDMaybeProxy.swift
//  xxf_ios
//
//  Created by xxf on 5/27.
//

import RxSwift
import XXFFlow

public class ProgressHUDMaybeProxy<Element>: PrimitiveSequenceType {
    public typealias Trait = MaybeTrait
    public typealias Element = Element

    private let source: Maybe<Element>
    private let progressHudHandler: ProgressHudHandler
    private let loadingNotice: String?
    private let successNotice: String?
    private let errorNotice: String?

    public init(source: Maybe<Element>,
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

    public var primitiveSequence: PrimitiveSequence<MaybeTrait, Element> {
        source.do(onNext: { [weak self] value in
            self?.progressHudHandler.onNext(value, successNotice: self?.successNotice)
        }, onError: { [weak self] error in
            self?.progressHudHandler.onError(error, errorNotice: self?.errorNotice)
        }, onCompleted: { [weak self] in
            self?.progressHudHandler.onComplete(successNotice: self?.successNotice)
        }, onSubscribe: { [weak self] in
            self?.progressHudHandler.onSubscribe(loadingNotice: self?.loadingNotice)
        })
    }
}
