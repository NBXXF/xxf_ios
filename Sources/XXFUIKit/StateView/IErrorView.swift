//
//  IErrorView.swift
//  xxf_ios
//
//  Created by xxf on 2023/3/25.
//

#if canImport(UIKit)
import UIKit

/// 错误视图协议
@MainActor
public protocol IErrorView: UIView {
    /// 标题
    var title: String? { get set }

    /// 描述文字（错误详情）
    var message: String? { get set }

    /// 重试按钮点击回调
    var onRetry: (() -> Void)? { get set }
}

#endif
