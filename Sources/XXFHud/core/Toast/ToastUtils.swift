//
//  ToastUtils.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/27.
//

import Foundation

public enum ToastUtils {
    public nonisolated(unsafe) static var toastDelegate: ToastDelegate?
    public static func showToast(text: String) {
        if let delegate = toastDelegate {
            delegate.showToast(text: text)
        }
    }
}
