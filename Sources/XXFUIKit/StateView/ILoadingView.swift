//
//  ILoadingView.swift
//  xxf_ios
//
//  Created by xxf on 2023/3/25.
//

#if canImport(UIKit)
import UIKit

/// 加载中视图协议
@MainActor
public protocol ILoadingView: UIView {
    /// 开始加载动画
    func startLoading()

    /// 停止加载动画
    func stopLoading()
}

#endif
