//
//  IEmptyView.swift
//  xxf_ios
//
//  Created by xxf on 2026/3/25.
//

#if canImport(UIKit)
import UIKit

/// 空数据视图协议
@MainActor
public protocol IEmptyView: UIView {
    /// 标题
    var title: String? { get set }

    /// 描述文字
    var message: String? { get set }

    /// 重试按钮点击回调
    var onRetry: (() -> Void)? { get set }
}

#endif
