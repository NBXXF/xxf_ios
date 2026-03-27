//
//  DefaultErrorHandler.swift
//  xxf_ios
//
//  Created by xxf on 5/27.
//
import XXFFlow

public class DefaultErrorHandler: ErrorHandler {
    /// 支持外部覆盖
    public nonisolated(unsafe) static var shared: ErrorHandler = DefaultErrorHandler()

    public func handle(error: any Error, toastPosition _: Int) {
        if error.isRxDisposedError {
            return
        }
        // 使用 ProgressHUD、Toast 或其他方式展示
        showToast(text: convert(error: error)) // 调用泛型版本
    }

    // 保留这个方法做兼容入口，但仅转发给泛型版本
    @inline(__always)
    public func convert(error: any Error) -> String {
        return error.localizedDescription
    }
}
