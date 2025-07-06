//
//  ProgressHudHandler.swift
//  xxf_ios
//
//  Created by xxf on 5/27.
//

public protocol ProgressHudHandler {
    /// 开始执行（订阅时）
    func onSubscribe(loadingNotice: String?)

    /// 接收到数据（可能多次）
    func onNext(_ value: Any?, successNotice: String?)

    /// 成功完成
    func onComplete(successNotice: String?)

    /// 发生错误
    func onError(_ error: Error, errorNotice: String?)

    /// 被取消（可选，实现需要额外逻辑）
    func onDispose()
}
