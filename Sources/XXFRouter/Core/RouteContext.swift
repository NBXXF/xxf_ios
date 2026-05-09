//
//  RouteContext.swift
//  XXFRouter
//
//  路由上下文定义
//

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

