//
//  Router+Extension.swift
//  XXFRouter
//
//  路由器扩展功能
//  Created by XXF on 2024
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - URL 扩展

public extension URL {
    /// 转换为路由上下文
    /// - Parameters:
    ///   - extraParameters: 额外参数
    ///   - flags: 路由标志位
    /// - Returns: 路由上下文
    func toRouteContext(
        extraParameters: RouteParameters = [:],
        flags: RouteFlags = .none
    ) -> RouteContext {
        var queryParams: RouteQueryItems = [:]

        if let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for item in queryItems {
                queryParams[item.name] = item.value ?? ""
            }
        }

        return RouteContext(
            url: absoluteString,
            queryParameters: queryParams,
            extraParameters: extraParameters,
            flags: flags
        )
    }

    /// 使用路由器导航到此URL
    /// - Parameters:
    ///   - options: 导航选项
    ///   - completion: 完成回调
    @MainActor
    func navigate(
        options: RouteOptions? = nil,
        completion: (@Sendable (RouteResult) -> Void)? = nil
    ) {
        Router.shared.navigate(
            to: absoluteString,
            options: options,
            completion: completion
        )
    }
}

// MARK: - String 扩展

public extension String {
    /// 使用路由器导航到此URL字符串
    /// - Parameters:
    ///   - extraParameters: 额外参数
    ///   - options: 导航选项
    ///   - completion: 完成回调
    @MainActor
    func navigate(
        extraParameters: RouteParameters = [:],
        options: RouteOptions? = nil,
        completion: (@Sendable (RouteResult) -> Void)? = nil
    ) {
        Router.shared.navigate(
            to: self,
            extraParameters: extraParameters,
            options: options,
            completion: completion
        )
    }

    /// 检查此URL字符串是否可以路由
    @MainActor
    var isRoutable: Bool {
        return Router.shared.canRoute(to: self)
    }

    /// 获取此URL对应的视图控制器
    /// - Parameter extraParameters: 额外参数
    /// - Returns: 视图控制器
    @MainActor
    func toViewController(
        extraParameters: RouteParameters = [:]
    ) -> RouteViewController? {
        return Router.shared.viewController(for: self, extraParameters: extraParameters)
    }
}

// MARK: - 视图控制器扩展

#if canImport(UIKit)
public extension UIViewController {
    /// 从当前视图控制器导航到指定URL
    /// - Parameters:
    ///   - url: 目标URL
    ///   - extraParameters: 额外参数
    ///   - options: 导航选项
    ///   - completion: 完成回调
    func navigate(
        to url: String,
        extraParameters: RouteParameters = [:],
        options: RouteOptions? = nil,
        completion: (@Sendable (RouteResult) -> Void)? = nil
    ) {
        Router.shared.navigate(
            to: url,
            extraParameters: extraParameters,
            options: options,
            from: self,
            completion: completion
        )
    }

    /// Push导航到指定URL
    /// - Parameters:
    ///   - url: 目标URL
    ///   - extraParameters: 额外参数
    ///   - animated: 是否动画
    ///   - completion: 完成回调
    func push(
        to url: String,
        extraParameters: RouteParameters = [:],
        animated: Bool = true,
        completion: (@Sendable (RouteResult) -> Void)? = nil
    ) {
        Router.shared.push(
            to: url,
            extraParameters: extraParameters,
            from: self,
            animated: animated,
            completion: completion
        )
    }

    /// Present导航到指定URL
    /// - Parameters:
    ///   - url: 目标URL
    ///   - extraParameters: 额外参数
    ///   - animated: 是否动画
    ///   - completion: 完成回调
    func present(
        to url: String,
        extraParameters: RouteParameters = [:],
        animated: Bool = true,
        completion: (@Sendable (RouteResult) -> Void)? = nil
    ) {
        Router.shared.present(
            to: url,
            extraParameters: extraParameters,
            from: self,
            animated: animated,
            completion: completion
        )
    }
}
#endif

#if canImport(AppKit)
public extension NSViewController {
    /// 从当前视图控制器导航到指定URL
    /// - Parameters:
    ///   - url: 目标URL
    ///   - extraParameters: 额外参数
    ///   - options: 导航选项
    ///   - completion: 完成回调
    func navigate(
        to url: String,
        extraParameters: RouteParameters = [:],
        options: RouteOptions? = nil,
        completion: (@Sendable (RouteResult) -> Void)? = nil
    ) {
        Router.shared.navigate(
            to: url,
            extraParameters: extraParameters,
            options: options,
            from: self,
            completion: completion
        )
    }
}
#endif

// MARK: - 路由构建器

/// 路由URL构建器
public struct RouteURLBuilder: Sendable {
    private var scheme: String
    private var host: String
    private var pathComponents: [String]
    private var queryItems: [String: String]

    /// 创建路由URL构建器
    /// - Parameters:
    ///   - scheme: URL scheme
    ///   - host: 主机名
    public init(scheme: String = "app", host: String = "") {
        self.scheme = scheme
        self.host = host
        self.pathComponents = []
        self.queryItems = [:]
    }

    /// 添加路径组件
    /// - Parameter component: 路径组件
    /// - Returns: 构建器
    public func path(_ component: String) -> RouteURLBuilder {
        var builder = self
        builder.pathComponents.append(component)
        return builder
    }

    /// 添加查询参数
    /// - Parameters:
    ///   - key: 参数名
    ///   - value: 参数值
    /// - Returns: 构建器
    public func query(_ key: String, _ value: String) -> RouteURLBuilder {
        var builder = self
        builder.queryItems[key] = value
        return builder
    }

    /// 添加查询参数（可选值）
    /// - Parameters:
    ///   - key: 参数名
    ///   - value: 参数值
    /// - Returns: 构建器
    public func query(_ key: String, _ value: String?) -> RouteURLBuilder {
        guard let value = value else { return self }
        var builder = self
        builder.queryItems[key] = value
        return builder
    }

    /// 构建URL字符串
    /// - Returns: URL字符串
    public func build() -> String {
        var urlString = "\(scheme)://"

        if !host.isEmpty {
            urlString += host
        }

        if !pathComponents.isEmpty {
            // 对路径组件进行 URL 编码
            let encodedComponents = pathComponents.map { component in
                component.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? component
            }
            urlString += "/" + encodedComponents.joined(separator: "/")
        }

        if !queryItems.isEmpty {
            // 对查询参数进行 URL 编码
            let encodedQueryItems = queryItems.map { key, value in
                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value
                return "\(encodedKey)=\(encodedValue)"
            }
            urlString += "?" + encodedQueryItems.joined(separator: "&")
        }

        return urlString
    }

    /// 导航到构建的URL
    /// - Parameters:
    ///   - extraParameters: 额外参数
    ///   - options: 导航选项
    ///   - completion: 完成回调
    @MainActor
    public func navigate(
        extraParameters: RouteParameters = [:],
        options: RouteOptions? = nil,
        completion: (@Sendable (RouteResult) -> Void)? = nil
    ) {
        Router.shared.navigate(
            to: build(),
            extraParameters: extraParameters,
            options: options,
            completion: completion
        )
    }
}

// MARK: - 便捷方法

/// 全局路由导航函数
/// - Parameters:
///   - url: 目标URL
///   - extraParameters: 额外参数
///   - options: 导航选项
///   - completion: 完成回调
@MainActor
public func navigate(
    to url: String,
    extraParameters: RouteParameters = [:],
    options: RouteOptions? = nil,
    completion: (@Sendable (RouteResult) -> Void)? = nil
) {
    Router.shared.navigate(
        to: url,
        extraParameters: extraParameters,
        options: options,
        completion: completion
    )
}

/// 创建路由URL构建器
/// - Parameters:
///   - scheme: URL scheme
///   - host: 主机名
/// - Returns: 构建器
public func routeURL(scheme: String = "app", host: String = "") -> RouteURLBuilder {
    return RouteURLBuilder(scheme: scheme, host: host)
}
