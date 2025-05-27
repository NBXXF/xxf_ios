//
//  Maybe+Hud.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/26.
//

import RxSwift

public extension PrimitiveSequence where Trait == MaybeTrait {
    /// 绑定流错误显示
    func bindErrorNotice(
        toastPosition: Int = 0,
        filter: @escaping (Error) -> Bool = { _ in true },
        errorHandler: ErrorHandler? = nil
    ) -> PrimitiveSequence<MaybeTrait, Element> {
        // self 已经是 Maybe 了，不需要调用 asMaybe()
        return ErrorMaybeProxy(
            source: self,
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
    ) -> PrimitiveSequence<MaybeTrait, Element> {
        return ProgressHUDMaybeProxy(
            source: self,
            progressHudHandler: handler ?? DefaultProgressHudHandler.shared,
            loadingNotice: loadingNotice,
            successNotice: successNotice,
            errorNotice: errorNotice
        ).primitiveSequence
    }
}
