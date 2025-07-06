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
        // 使用 ProgressHUD、Toast 或其他方式展示
        showToast(text: convertGeneric(error)) // 调用泛型版本
    }

    // 保留这个方法做兼容入口，但仅转发给泛型版本
    @inline(__always)
    public func convert(error: any Error) -> String {
        // 调用内部泛型函数，避免类型擦除代价
        return convertGeneric(error)
    }

    // 泛型版本，避免类型擦除，提高性能
    @inline(__always)
    private func convertGeneric<E: Error>(_ error: E) -> String {
        return error.localizedDescription
    }
}
