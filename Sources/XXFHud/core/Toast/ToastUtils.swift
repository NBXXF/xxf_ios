//
//  ToastUtils.swift
//  xxf_ios
//
//  Created by xxf on 5/27.
//

import Foundation

public enum ToastUtils {
    public nonisolated(unsafe) static var toastDelegate: ToastDelegate?
    public static func showToast(text: String) {
        func call() {
            if let delegate = toastDelegate {
                delegate.showToast(text: text)
            }
        }

        if Thread.isMainThread {
            call()
        } else {
            DispatchQueue.main.async {
                call()
            }
        }
    }
}
