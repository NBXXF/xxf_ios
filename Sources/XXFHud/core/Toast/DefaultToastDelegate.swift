//
//  DefaultToastDelegate.swift
//  xxf_ios
//
//  Created by xxf on 2025/11/13.
//

#if os(iOS)
import Toast
struct DefaultToastDelegate:ToastDelegate{
    func showToast(text: String) {
        let toast = Toast.text(text)
        toast.show()
    }
}
#endif
