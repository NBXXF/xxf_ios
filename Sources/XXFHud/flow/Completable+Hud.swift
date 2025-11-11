
//
//  Completable+Hud.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//

import RxSwift

public extension PrimitiveSequence where Trait == CompletableTrait, Element == Never {
    func bindErrorNotice(
        toastPosition: Int = 0,
        filter: @escaping (Error) -> Bool = { _ in true },
        errorHandler: ErrorHandler? = nil
    ) -> PrimitiveSequence<CompletableTrait, Element> {
        return ErrorCompletableProxy(
            source: self, // 这里的 self 是 PrimitiveSequence<CompletableTrait, Never>
            errorHandler: errorHandler ?? DefaultErrorHandler.shared,
            toastPosition: toastPosition,
            filter: filter
        ).primitiveSequence
    }

    /// 在流开始时显示加载 HUD，完成时显示成功提示，出错时显示错误提示
    ///
    /// - Parameters:
    ///   - loadingNotice: 加载时的提示文字，默认无文字
    ///   - successNotice: 成功完成时的提示文字，默认无文字
    ///   - errorNotice: 出错时的提示文字，默认使用 error.localizedDescription
    /// - Returns: 包装了 HUD 行为的 Observable
    func bindProgressHud(
        loadingNotice: String? = nil,
        successNotice: String? = nil,
        errorNotice: String? = nil,
        handler: ProgressHudHandler? = nil
    ) -> PrimitiveSequence<CompletableTrait, Element> {
        return ProgressHUDCompletableProxy(
            source: self,
            progressHudHandler: handler ?? ProgressHudUtils.progressHudHandler,
            loadingNotice: loadingNotice,
            successNotice: successNotice,
            errorNotice: errorNotice
        ).primitiveSequence
    }
}
