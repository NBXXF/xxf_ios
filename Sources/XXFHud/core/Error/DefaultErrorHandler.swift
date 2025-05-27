//
//  DefaultErrorHandler.swift
//  xxf_ios
//
//  Created by trl on 2025/5/27.
//
import ProgressHUD

public class DefaultErrorHandler: ErrorHandler {
    /// 支持外部覆盖
    public nonisolated(unsafe) static var shared: ErrorHandler = DefaultErrorHandler()

    public func handle(error: any Error, toastPosition _: Int) {
        // 使用 ProgressHUD、Toast 或其他方式展示
        ProgressHUD.failed("出错了：\(error.localizedDescription)")
    }
}
