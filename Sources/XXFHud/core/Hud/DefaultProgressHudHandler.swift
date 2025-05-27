//
//  DefaultProgressHudHandler.swift
//  xxf_ios
//
//  Created by trl on 2025/5/27.
//

import Foundation
import ProgressHUD
import RxSwift

public class DefaultProgressHudHandler: ProgressHudHandler {
    /// 支持外部覆盖
    public nonisolated(unsafe) static var shared: ProgressHudHandler = DefaultProgressHudHandler()

    public init() {}

    public func onSubscribe(loadingNotice: String?) {
        // 订阅时显示加载框
        DispatchQueue.main.async {
            ProgressHUD.animate(loadingNotice)
        }
    }

    public func onNext(_: Any?, successNotice: String?) {
        // 完成时隐藏
        DispatchQueue.main.async {
            ProgressHUD.succeed(successNotice)
        }
    }

    public func onComplete(successNotice: String?) {
        // 完成时隐藏
        DispatchQueue.main.async {
            ProgressHUD.succeed(successNotice)
        }
    }

    public func onError(_ error: Error, errorNotice: String?) {
        // 出错时显示错误提示
        DispatchQueue.main.async {
            ProgressHUD.failed(errorNotice ?? error.localizedDescription)
        }
    }

    public func onDispose() {
        // 出错时显示错误提示
        DispatchQueue.main.async {
            ProgressHUD.dismiss()
        }
    }
}
