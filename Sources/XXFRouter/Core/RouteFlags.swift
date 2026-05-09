//
//  RouteFlags.swift
//  XXFRouter
//
//  路由标志位定义
//

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

