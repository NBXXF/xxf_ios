//
//  RouteTypes.swift
//  XXFRouter
//
//  核心路由类型定义
//  Created by XXF on 2024
//

#if canImport(UIKit)
import UIKit
/// 视图控制器类型别名
public typealias RouteViewController = UIViewController
/// 导航控制器类型别名
public typealias RouteNavigationController = UINavigationController
#elseif canImport(AppKit)
import AppKit
/// 视图控制器类型别名
public typealias RouteViewController = NSViewController
/// 导航控制器类型别名
public typealias RouteNavigationController = NSViewController
#endif

// MARK: - 路由标志位

/// 路由标志位，用于在注册时指定路由的特殊行为
/// 例如：需要登录验证、需要实名认证等
public struct RouteFlags: OptionSet, Sendable, Hashable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    /// 无特殊标志
    public static let none = RouteFlags([])

    /// 需要登录验证
    public static let requiresLogin = RouteFlags(rawValue: 1 << 0)

    /// 需要实名认证
    public static let requiresRealName = RouteFlags(rawValue: 1 << 1)

    /// 需要VIP权限
    public static let requiresVIP = RouteFlags(rawValue: 1 << 2)

    /// 单例模式（同一路由只能存在一个实例）
    public static let singleton = RouteFlags(rawValue: 1 << 3)

    /// 允许在后台打开
    public static let allowBackground = RouteFlags(rawValue: 1 << 4)

    /// 自定义标志位起始位置（用户可从此位开始定义自己的标志）
    public static let customFlagStart: UInt = 16

    /// 创建自定义标志位
    /// - Parameter offset: 相对于 customFlagStart 的偏移量 (0-15)
    /// - Returns: 自定义标志位
    public static func custom(_ offset: UInt) -> RouteFlags {
        precondition(offset < 16, "Custom flag offset must be less than 16")
        return RouteFlags(rawValue: 1 << (customFlagStart + offset))
    }
}

// MARK: - 路由参数

/// 路由参数字典类型别名
public typealias RouteParameters = [String: Any]

/// 路由查询参数类型别名
public typealias RouteQueryItems = [String: String]

// MARK: - 路由上下文

/// 路由上下文，包含路由导航所需的所有信息
public struct RouteContext: @unchecked Sendable {
    /// 原始URL字符串
    public let url: String

    /// 路由模式（不含参数的路径模板）
    public let pattern: String

    /// URL中解析出的路径参数
    public let pathParameters: RouteParameters

    /// URL中解析出的查询参数
    public let queryParameters: RouteQueryItems

    /// 额外传递的参数（非URL参数）
    public let extraParameters: RouteParameters

    /// 路由标志位
    public let flags: RouteFlags

    /// 发起导航的来源视图控制器
    public weak var sourceViewController: RouteViewController?

    /// 用户信息，可用于传递自定义数据
    public var userInfo: [String: Any]

    /// 创建路由上下文
    /// - Parameters:
    ///   - url: 原始URL字符串
    ///   - pattern: 路由模式
    ///   - pathParameters: 路径参数
    ///   - queryParameters: 查询参数
    ///   - extraParameters: 额外参数
    ///   - flags: 路由标志位
    ///   - sourceViewController: 来源视图控制器
    ///   - userInfo: 用户信息
    public init(
        url: String,
        pattern: String = "",
        pathParameters: RouteParameters = [:],
        queryParameters: RouteQueryItems = [:],
        extraParameters: RouteParameters = [:],
        flags: RouteFlags = .none,
        sourceViewController: RouteViewController? = nil,
        userInfo: [String: Any] = [:]
    ) {
        self.url = url
        self.pattern = pattern
        self.pathParameters = pathParameters
        self.queryParameters = queryParameters
        self.extraParameters = extraParameters
        self.flags = flags
        self.sourceViewController = sourceViewController
        self.userInfo = userInfo
    }

    /// 获取所有参数（路径参数 + 查询参数 + 额外参数）
    /// 优先级：extraParameters > pathParameters > queryParameters
    public var allParameters: RouteParameters {
        var result: RouteParameters = [:]

        // 查询参数优先级最低
        for (key, value) in queryParameters {
            result[key] = value
        }

        // 路径参数覆盖查询参数
        for (key, value) in pathParameters {
            result[key] = value
        }

        // 额外参数优先级最高
        for (key, value) in extraParameters {
            result[key] = value
        }

        return result
    }

    /// 获取指定类型的参数值
    /// - Parameters:
    ///   - key: 参数键
    ///   - type: 目标类型
    /// - Returns: 转换后的值，如果不存在或转换失败则返回nil
    public func parameter<T>(for key: String, as type: T.Type = T.self) -> T? {
        return allParameters[key] as? T
    }

    /// 获取字符串参数
    /// - Parameter key: 参数键
    /// - Returns: 字符串值
    public func string(for key: String) -> String? {
        if let value = allParameters[key] {
            return String(describing: value)
        }
        return nil
    }

    /// 获取整数参数
    /// - Parameter key: 参数键
    /// - Returns: 整数值
    public func int(for key: String) -> Int? {
        if let intValue = allParameters[key] as? Int {
            return intValue
        }
        if let stringValue = allParameters[key] as? String {
            return Int(stringValue)
        }
        return nil
    }

    /// 获取布尔参数
    /// - Parameter key: 参数键
    /// - Returns: 布尔值
    public func bool(for key: String) -> Bool? {
        if let boolValue = allParameters[key] as? Bool {
            return boolValue
        }
        if let stringValue = allParameters[key] as? String {
            return stringValue.lowercased() == "true" || stringValue == "1"
        }
        if let intValue = allParameters[key] as? Int {
            return intValue != 0
        }
        return nil
    }
}

// MARK: - 导航方式

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

// MARK: - 路由配置

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

// MARK: - 路由错误

/// 路由错误类型
public enum RouteError: Error, Sendable, CustomStringConvertible {
    /// 路由未找到
    case notFound(url: String)

    /// 被拦截器拦截
    case intercepted(reason: String)

    /// 创建视图控制器失败
    case viewControllerCreationFailed(url: String)

    /// 导航失败
    case navigationFailed(reason: String)

    /// 服务未找到
    case serviceNotFound(protocol: String)

    /// 无效的URL格式
    case invalidURL(url: String)

    /// 缺少必需参数
    case missingRequiredParameter(name: String)

    /// 参数类型错误
    case invalidParameterType(name: String, expected: String, actual: String)

    /// 自定义错误
    case custom(code: Int, message: String)

    public var description: String {
        switch self {
        case .notFound(let url):
            return "Route not found: \(url)"
        case .intercepted(let reason):
            return "Route intercepted: \(reason)"
        case .viewControllerCreationFailed(let url):
            return "Failed to create view controller for: \(url)"
        case .navigationFailed(let reason):
            return "Navigation failed: \(reason)"
        case .serviceNotFound(let proto):
            return "Service not found for protocol: \(proto)"
        case .invalidURL(let url):
            return "Invalid URL format: \(url)"
        case .missingRequiredParameter(let name):
            return "Missing required parameter: \(name)"
        case .invalidParameterType(let name, let expected, let actual):
            return "Invalid parameter type for '\(name)': expected \(expected), got \(actual)"
        case .custom(let code, let message):
            return "Error(\(code)): \(message)"
        }
    }
}
