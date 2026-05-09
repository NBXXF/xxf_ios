//
//  RouteOptions.swift
//  XXFRouter
//
//  路由配置选项
//

#if canImport(UIKit)
import UIKit
#endif

/// 路由配置选项
public struct RouteOptions: @unchecked Sendable {
    /// 导航方式
    public var navigationType: NavigationType

    /// 是否带动画
    public var animated: Bool

    #if canImport(UIKit)
    /// Modal展示样式（仅对present有效）
    public var modalPresentationStyle: UIModalPresentationStyle

    /// Modal过渡样式（仅对present有效）
    public var modalTransitionStyle: UIModalTransitionStyle

    /// Push时是否隐藏底部TabBar（仅对push有效）
    public var hidesBottomBarWhenPushed: Bool

    /// Present时是否自动包装NavigationController（仅对present有效）
    public var wrapInNavigationController: Bool
    #endif

    /// 是否在导航前关闭当前模态视图
    public var dismissBeforeNavigation: Bool

    /// 自定义过渡动画
    public var customTransition: Any?

    /// 导航完成回调
    public var completion: (() -> Void)?

    #if canImport(UIKit)
    /// 创建路由配置
    /// - Parameters:
    ///   - navigationType: 导航方式，默认为push
    ///   - animated: 是否带动画，默认为true
    ///   - modalPresentationStyle: Modal展示样式
    ///   - modalTransitionStyle: Modal过渡样式
    ///   - hidesBottomBarWhenPushed: Push时是否隐藏底部TabBar
    ///   - wrapInNavigationController: Present时是否包装NavigationController
    ///   - dismissBeforeNavigation: 是否在导航前关闭当前模态视图
    ///   - customTransition: 自定义过渡动画
    ///   - completion: 导航完成回调
    public init(
        navigationType: NavigationType = .push,
        animated: Bool = true,
        modalPresentationStyle: UIModalPresentationStyle = .automatic,
        modalTransitionStyle: UIModalTransitionStyle = .coverVertical,
        hidesBottomBarWhenPushed: Bool = false,
        wrapInNavigationController: Bool = false,
        dismissBeforeNavigation: Bool = false,
        customTransition: Any? = nil,
        completion: (() -> Void)? = nil
    ) {
        self.navigationType = navigationType
        self.animated = animated
        self.modalPresentationStyle = modalPresentationStyle
        self.modalTransitionStyle = modalTransitionStyle
        self.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
        self.wrapInNavigationController = wrapInNavigationController
        self.dismissBeforeNavigation = dismissBeforeNavigation
        self.customTransition = customTransition
        self.completion = completion
    }
    #else
    /// 创建路由配置
    /// - Parameters:
    ///   - navigationType: 导航方式，默认为push
    ///   - animated: 是否带动画，默认为true
    ///   - dismissBeforeNavigation: 是否在导航前关闭当前模态视图
    ///   - customTransition: 自定义过渡动画
    ///   - completion: 导航完成回调
    public init(
        navigationType: NavigationType = .push,
        animated: Bool = true,
        dismissBeforeNavigation: Bool = false,
        customTransition: Any? = nil,
        completion: (() -> Void)? = nil
    ) {
        self.navigationType = navigationType
        self.animated = animated
        self.dismissBeforeNavigation = dismissBeforeNavigation
        self.customTransition = customTransition
        self.completion = completion
    }
    #endif

    // MARK: - 预设配置

    /// 默认Push配置
    public static let push = RouteOptions(navigationType: .push)

    /// 默认Present配置
    public static let present = RouteOptions(navigationType: .present)

    /// 替换配置
    public static let replace = RouteOptions(navigationType: .replace)

    #if canImport(UIKit)
    /// Push并隐藏TabBar（适用于二级页面）
    public static let pushHideTabBar = RouteOptions(
        navigationType: .push,
        hidesBottomBarWhenPushed: true
    )

    /// 全屏Present（带NavigationController）
    public static let presentFullScreen = RouteOptions(
        navigationType: .present,
        modalPresentationStyle: .fullScreen,
        wrapInNavigationController: true
    )

    /// 全屏Present（不带NavigationController）
    public static let presentFullScreenWithoutNav = RouteOptions(
        navigationType: .present,
        modalPresentationStyle: .fullScreen
    )

    /// 替换根视图控制器（淡入淡出动画）
    public static let replaceRoot = RouteOptions(
        navigationType: .replaceRoot(transition: .crossDissolve)
    )

    /// 替换根视图控制器（无动画）
    public static let replaceRootWithoutAnimation = RouteOptions(
        navigationType: .replaceRoot(transition: .none)
    )
    #endif
}

