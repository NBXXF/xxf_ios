//
//  EmptyProgressHudHandler.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/27.
//

class EmptyProgressHudHandler: ProgressHudHandler {
    func onSubscribe(loadingNotice _: String?) {}

    func onNext(_: Any?, successNotice _: String?) {}

    func onComplete(successNotice _: String?) {}

    func onError(_: any Error, errorNotice _: String?) {}

    func onDispose() {}
}

// public class DefaultProgressHudHandler: ProgressHudHandler {
//    /// 支持外部覆盖
//    public nonisolated(unsafe) static var shared: ProgressHudHandler = DefaultProgressHudHandler()
//
//    public init() {}
//
//    public func onSubscribe(loadingNotice: String?) {
//        // 订阅时显示加载框
//        DispatchQueue.main.async {
//            ProgressHUD.animate(loadingNotice)
//        }
//    }
//
//    public func onNext(_: Any?, successNotice: String?) {
//        // 完成时隐藏
//        DispatchQueue.main.async {
//            ProgressHUD.succeed(successNotice)
//        }
//    }
//
//    public func onComplete(successNotice: String?) {
//        // 完成时隐藏
//        DispatchQueue.main.async {
//            ProgressHUD.succeed(successNotice)
//        }
//    }
//
//    public func onError(_ error: Error, errorNotice: String?) {
//        // 出错时显示错误提示
//        DispatchQueue.main.async {
//            ProgressHUD.failed(errorNotice ?? DefaultErrorHandler.shared.convert(error: error))
//        }
//    }
//
//    public func onDispose() {
//        // 出错时显示错误提示
//        DispatchQueue.main.async {
//            ProgressHUD.dismiss()
//        }
//    }
// }
