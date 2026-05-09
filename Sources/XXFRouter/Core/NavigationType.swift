//
//  NavigationType.swift
//  XXFRouter
//
//  导航方式定义
//

import Foundation

/// 导航方式枚举
public enum NavigationType: Sendable {
    /// Push导航（需要导航控制器）
    case push

    /// Modal弹出
    case present

    /// 替换当前视图控制器（在导航栈中替换）
    case replace

    /// 替换根视图控制器（替换 window.rootViewController）
    /// - Parameter transition: 过渡动画选项（可选）
    case replaceRoot(transition: RootTransition = .crossDissolve)

    /// 自定义导航方式
    case custom(@Sendable (RouteViewController, RouteViewController) -> Void)
}

/// 根视图控制器替换过渡动画
public enum RootTransition: Sendable {
    /// 淡入淡出
    case crossDissolve
    /// 无动画
    case none
    /// 从右滑入（类似 push）
    case slideFromRight
    /// 从底部滑入（类似 present）
    case slideFromBottom
    /// 自定义动画时长
    case custom(duration: TimeInterval)
}

