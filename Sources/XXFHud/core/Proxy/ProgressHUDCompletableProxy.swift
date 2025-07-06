
//
//  ProgressHUDCompletableProxy.swift
//  xxf_ios
//
//  Created by xxf on 5/27.
//

import RxSwift
import XXFFlow

public class ProgressHUDCompletableProxy: PrimitiveSequenceType {
    public typealias Trait = CompletableTrait
    public typealias Element = Never

    private let source: Completable
    private let progressHudHandler: ProgressHudHandler
    private let loadingNotice: String?
    private let successNotice: String?
    private let errorNotice: String?

    public init(source: Completable,
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

    public var primitiveSequence: PrimitiveSequence<CompletableTrait, Never> {
        source.do(onError: { [weak self] error in
            self?.progressHudHandler.onError(error, errorNotice: self?.errorNotice)
        }, onCompleted: { [weak self] in
            self?.progressHudHandler.onComplete(successNotice: self?.successNotice)
        }, onSubscribe: { [weak self] in
            self?.progressHudHandler.onSubscribe(loadingNotice: self?.loadingNotice)
        })
    }
}
