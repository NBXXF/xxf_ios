//
//  ToastDelegate.swift
//  xxf_ios
//
//  Created by xxf on 5/27.
//
public protocol ToastDelegate {
    func showToast(text: String)
}
#if os(iOS)
import Toast
struct DefaultToastDelegate:ToastDelegate{
    func showToast(text: String) {
        let toast = Toast.text(text)
        toast.show()
    }
}
#endif
