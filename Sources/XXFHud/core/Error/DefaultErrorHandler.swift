//
//  DefaultErrorHandler.swift
//  xxf_ios
//
//  Created by xxf on /5/27.
//

public class DefaultErrorHandler: ErrorHandler {
    /// 支持外部覆盖
    public nonisolated(unsafe) static var shared: ErrorHandler = DefaultErrorHandler()

    public func handle(error: any Error, toastPosition _: Int) {
        // 使用 ProgressHUD、Toast 或其他方式展示
        showToast(text: convert(error: error))
    }

    public func convert(error: any Error) -> String {
        return error.localizedDescription
    }
}
