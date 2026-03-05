//
//  BuiltinInterceptors.swift
//  XXFRouter
//
//  内置拦截器实现
//  Created by XXF on 2024
//

import Foundation

// MARK: - 登录拦截器

/// 登录检查拦截器
///
/// 用于检查需要登录的路由，如果用户未登录则重定向到登录页面
///
/// 使用示例：
/// ```swift
/// let loginInterceptor = LoginCheckInterceptor(
///     loginURL: "app://login",
///     isLoggedIn: { UserManager.shared.isLoggedIn }
/// )
/// Router.shared.registerInterceptor(loginInterceptor)
/// ```
public final class LoginCheckInterceptor: RouteInterceptor, @unchecked Sendable {
    public let name = "LoginCheckInterceptor"
    public let priority: Int
    public let targetFlags: RouteFlags = .requiresLogin

    /// 登录页面URL
    private let loginURL: String

    /// 登录状态检查闭包
    private let isLoggedIn: @Sendable () -> Bool

    /// 是否在登录后返回原页面
    private let returnAfterLogin: Bool

    /// 回调参数名
    private let callbackParamName: String

    /// 创建登录检查拦截器
    /// - Parameters:
    ///   - loginURL: 登录页面URL
    ///   - priority: 优先级
    ///   - returnAfterLogin: 是否在登录后返回原页面
    ///   - callbackParamName: 回调参数名
    ///   - isLoggedIn: 登录状态检查闭包
    public init(
        loginURL: String,
        priority: Int = InterceptorPriority.high,
        returnAfterLogin: Bool = true,
        callbackParamName: String = "callback",
        isLoggedIn: @escaping @Sendable () -> Bool
    ) {
        self.loginURL = loginURL
        self.priority = priority
        self.returnAfterLogin = returnAfterLogin
        self.callbackParamName = callbackParamName
        self.isLoggedIn = isLoggedIn
    }

    public func intercept(context: RouteContext, chain: InterceptorChain) {
        if isLoggedIn() {
            chain.proceed()
        } else {
            if returnAfterLogin {
                // 添加回调参数
                let encodedURL = context.url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? context.url
                let redirectURL = "\(loginURL)?\(callbackParamName)=\(encodedURL)"
                chain.redirect(to: redirectURL)
            } else {
                chain.redirect(to: loginURL)
            }
        }
    }
}

// MARK: - 实名认证拦截器

/// 实名认证检查拦截器
public final class RealNameCheckInterceptor: RouteInterceptor, @unchecked Sendable {
    public let name = "RealNameCheckInterceptor"
    public let priority: Int
    public let targetFlags: RouteFlags = .requiresRealName

    /// 实名认证页面URL
    private let verificationURL: String

    /// 实名认证状态检查闭包
    private let isVerified: @Sendable () -> Bool

    /// 创建实名认证检查拦截器
    /// - Parameters:
    ///   - verificationURL: 实名认证页面URL
    ///   - priority: 优先级
    ///   - isVerified: 实名认证状态检查闭包
    public init(
        verificationURL: String,
        priority: Int = InterceptorPriority.high - 1, // 略低于登录拦截器
        isVerified: @escaping @Sendable () -> Bool
    ) {
        self.verificationURL = verificationURL
        self.priority = priority
        self.isVerified = isVerified
    }

    public func intercept(context: RouteContext, chain: InterceptorChain) {
        if isVerified() {
            chain.proceed()
        } else {
            chain.redirect(to: verificationURL)
        }
    }
}

// MARK: - VIP权限拦截器

/// VIP权限检查拦截器
public final class VIPCheckInterceptor: RouteInterceptor, @unchecked Sendable {
    public let name = "VIPCheckInterceptor"
    public let priority: Int
    public let targetFlags: RouteFlags = .requiresVIP

    /// VIP购买页面URL
    private let purchaseURL: String

    /// VIP状态检查闭包
    private let isVIP: @Sendable () -> Bool

    /// 拒绝时的提示消息
    private let rejectMessage: String

    /// 创建VIP权限检查拦截器
    /// - Parameters:
    ///   - purchaseURL: VIP购买页面URL
    ///   - priority: 优先级
    ///   - rejectMessage: 拒绝时的提示消息
    ///   - isVIP: VIP状态检查闭包
    public init(
        purchaseURL: String,
        priority: Int = InterceptorPriority.high - 2,
        rejectMessage: String = "This feature requires VIP membership",
        isVIP: @escaping @Sendable () -> Bool
    ) {
        self.purchaseURL = purchaseURL
        self.priority = priority
        self.rejectMessage = rejectMessage
        self.isVIP = isVIP
    }

    public func intercept(context: RouteContext, chain: InterceptorChain) {
        if isVIP() {
            chain.proceed()
        } else {
            chain.redirect(to: purchaseURL)
        }
    }
}

// MARK: - 单例路由拦截器

/// 单例路由拦截器，确保同一路由只有一个实例
public final class SingletonRouteInterceptor: RouteInterceptor, @unchecked Sendable {
    public let name = "SingletonRouteInterceptor"
    public let priority: Int
    public let targetFlags: RouteFlags = .singleton

    /// 活跃的单例路由（存储 pattern -> 时间戳）
    private var activeRoutes: [String: Date] = [:]
    private let lock = NSLock()

    /// 超时时间（秒），超时后自动清除，防止内存泄漏
    private let timeout: TimeInterval

    /// 创建单例路由拦截器
    /// - Parameters:
    ///   - priority: 优先级
    ///   - timeout: 单例路由超时时间（默认300秒），超时后自动释放
    public init(priority: Int = InterceptorPriority.highest, timeout: TimeInterval = 300) {
        self.priority = priority
        self.timeout = timeout
    }

    public func intercept(context: RouteContext, chain: InterceptorChain) {
        lock.lock()
        let pattern = context.pattern.isEmpty ? context.url : context.pattern
        let now = Date()

        // 清理过期的单例记录
        activeRoutes = activeRoutes.filter { now.timeIntervalSince($0.value) < timeout }

        if activeRoutes[pattern] != nil {
            lock.unlock()
            chain.reject(reason: "Route '\(pattern)' is already active (singleton)")
            return
        }

        activeRoutes[pattern] = now
        lock.unlock()

        chain.proceed()
    }

    /// 标记路由已关闭
    /// - Parameter pattern: 路由模式
    public func markClosed(pattern: String) {
        lock.lock()
        activeRoutes.removeValue(forKey: pattern)
        lock.unlock()
    }

    /// 通过 URL 标记路由已关闭（便捷方法）
    /// - Parameter url: 路由 URL
    public func markClosedByURL(_ url: String) {
        lock.lock()
        defer { lock.unlock() }

        // 直接尝试移除完整 URL
        activeRoutes.removeValue(forKey: url)

        // 提取路径部分尝试匹配
        if let urlComponents = URLComponents(string: url) {
            var pathKey = urlComponents.host ?? ""
            if !urlComponents.path.isEmpty {
                pathKey += urlComponents.path
            }
            // 标准化：移除开头和结尾的斜杠
            pathKey = pathKey.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

            // 查找匹配的 pattern（pattern 可能包含 URL 的路径部分）
            let keysToRemove = activeRoutes.keys.filter { pattern in
                let normalizedPattern = pattern.trimmingCharacters(in: CharacterSet(charactersIn: "/")).lowercased()
                return pathKey.lowercased() == normalizedPattern ||
                       pathKey.lowercased().hasPrefix(normalizedPattern + "/") ||
                       normalizedPattern.hasPrefix(pathKey.lowercased() + "/")
            }
            for key in keysToRemove {
                activeRoutes.removeValue(forKey: key)
            }
        }
    }

    /// 清除所有活跃路由记录
    public func clear() {
        lock.lock()
        activeRoutes.removeAll()
        lock.unlock()
    }

    /// 获取当前活跃的单例路由数量（用于调试）
    public var activeCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return activeRoutes.count
    }
}

// MARK: - 参数验证拦截器

/// 参数验证拦截器
public final class ParameterValidationInterceptor: RouteInterceptor, @unchecked Sendable {
    public let name: String
    public let priority: Int
    public let targetFlags: RouteFlags

    /// 验证规则
    public struct ValidationRule: Sendable {
        /// 参数名
        public let parameterName: String

        /// 是否必需
        public let required: Bool

        /// 验证闭包
        public let validator: (@Sendable (Any?) -> Bool)?

        /// 错误消息
        public let errorMessage: String

        /// 创建验证规则
        public init(
            parameterName: String,
            required: Bool = true,
            errorMessage: String? = nil,
            validator: (@Sendable (Any?) -> Bool)? = nil
        ) {
            self.parameterName = parameterName
            self.required = required
            self.validator = validator
            self.errorMessage = errorMessage ?? "Invalid parameter: \(parameterName)"
        }
    }

    /// 验证规则列表
    private let rules: [ValidationRule]

    /// 创建参数验证拦截器
    /// - Parameters:
    ///   - name: 拦截器名称
    ///   - priority: 优先级
    ///   - targetFlags: 目标标志位
    ///   - rules: 验证规则列表
    public init(
        name: String = "ParameterValidationInterceptor",
        priority: Int = InterceptorPriority.normal,
        targetFlags: RouteFlags = .none,
        rules: [ValidationRule]
    ) {
        self.name = name
        self.priority = priority
        self.targetFlags = targetFlags
        self.rules = rules
    }

    public func intercept(context: RouteContext, chain: InterceptorChain) {
        for rule in rules {
            let value = context.allParameters[rule.parameterName]

            // 检查必需参数
            if rule.required && value == nil {
                chain.reject(reason: "Missing required parameter: \(rule.parameterName)")
                return
            }

            // 执行自定义验证
            if let validator = rule.validator {
                if !validator(value) {
                    chain.reject(reason: rule.errorMessage)
                    return
                }
            }
        }

        chain.proceed()
    }
}

// MARK: - 埋点拦截器

/// 埋点/统计拦截器
public final class AnalyticsInterceptor: RouteInterceptor, @unchecked Sendable {
    public let name = "AnalyticsInterceptor"
    public let priority: Int
    public let targetFlags: RouteFlags = .none // 拦截所有路由

    /// 埋点回调
    private let trackHandler: @Sendable (RouteContext) -> Void

    /// 创建埋点拦截器
    /// - Parameters:
    ///   - priority: 优先级（通常设为最低，确保在所有验证后执行）
    ///   - trackHandler: 埋点回调
    public init(
        priority: Int = InterceptorPriority.lowest,
        trackHandler: @escaping @Sendable (RouteContext) -> Void
    ) {
        self.priority = priority
        self.trackHandler = trackHandler
    }

    public func intercept(context: RouteContext, chain: InterceptorChain) {
        // 执行埋点
        trackHandler(context)

        // 继续路由
        chain.proceed()
    }
}

// MARK: - 白名单/黑名单拦截器

/// URL白名单/黑名单拦截器
public final class URLFilterInterceptor: RouteInterceptor, @unchecked Sendable {
    public let name = "URLFilterInterceptor"
    public let priority: Int
    public let targetFlags: RouteFlags = .none

    /// 过滤模式
    public enum FilterMode: Sendable {
        /// 白名单模式（只允许列表中的URL）
        case whitelist
        /// 黑名单模式（禁止列表中的URL）
        case blacklist
    }

    /// 过滤模式
    private let mode: FilterMode

    /// URL模式列表
    private let patterns: [String]

    /// 拒绝消息
    private let rejectMessage: String

    /// 创建URL过滤拦截器
    /// - Parameters:
    ///   - mode: 过滤模式
    ///   - patterns: URL模式列表
    ///   - priority: 优先级
    ///   - rejectMessage: 拒绝消息
    public init(
        mode: FilterMode,
        patterns: [String],
        priority: Int = InterceptorPriority.highest,
        rejectMessage: String = "Access denied"
    ) {
        self.mode = mode
        self.patterns = patterns
        self.priority = priority
        self.rejectMessage = rejectMessage
    }

    public func intercept(context: RouteContext, chain: InterceptorChain) {
        let matches = patterns.contains { pattern in
            matchesPattern(url: context.url, pattern: pattern)
        }

        switch mode {
        case .whitelist:
            if matches {
                chain.proceed()
            } else {
                chain.reject(reason: rejectMessage)
            }

        case .blacklist:
            if matches {
                chain.reject(reason: rejectMessage)
            } else {
                chain.proceed()
            }
        }
    }

    /// 检查 URL 是否匹配模式
    /// 支持通配符 * 和精确匹配
    private func matchesPattern(url: String, pattern: String) -> Bool {
        let lowercasedURL = url.lowercased()
        let lowercasedPattern = pattern.lowercased()

        // 如果模式包含通配符
        if lowercasedPattern.contains("*") {
            // 将通配符转换为正则表达式
            let regexPattern = NSRegularExpression.escapedPattern(for: lowercasedPattern)
                .replacingOccurrences(of: "\\*", with: ".*")
            if let regex = try? NSRegularExpression(pattern: "^\(regexPattern)$", options: []) {
                let range = NSRange(lowercasedURL.startIndex..., in: lowercasedURL)
                return regex.firstMatch(in: lowercasedURL, options: [], range: range) != nil
            }
        }

        // 精确匹配：检查 URL 路径是否以 pattern 开头（边界匹配）
        // 例如 pattern "user" 应该匹配 "user" 或 "user/123"，但不匹配 "superuser"
        if let urlComponents = URLComponents(string: lowercasedURL) {
            let path = (urlComponents.host ?? "") + urlComponents.path
            let pathComponents = path.split(separator: "/").map(String.init)
            let patternComponents = lowercasedPattern.split(separator: "/").map(String.init)

            // 检查路径组件是否匹配
            if patternComponents.count <= pathComponents.count {
                let matchingPart = Array(pathComponents.prefix(patternComponents.count))
                if matchingPart == patternComponents {
                    return true
                }
            }
        }

        // 最后尝试简单的相等匹配
        return lowercasedURL == lowercasedPattern
    }
}

// MARK: - 频率限制拦截器

/// 频率限制拦截器，防止短时间内重复导航
public final class RateLimitInterceptor: RouteInterceptor, @unchecked Sendable {
    public let name = "RateLimitInterceptor"
    public let priority: Int
    public let targetFlags: RouteFlags = .none

    /// 时间窗口（秒）
    private let timeWindow: TimeInterval

    /// 最大次数
    private let maxCount: Int

    /// 访问记录
    private var accessRecords: [String: [Date]] = [:]
    private let lock = NSLock()

    /// 上次清理时间
    private var lastCleanupTime: Date = Date()

    /// 清理间隔（秒）
    private let cleanupInterval: TimeInterval = 60

    /// 创建频率限制拦截器
    /// - Parameters:
    ///   - timeWindow: 时间窗口（秒）
    ///   - maxCount: 时间窗口内最大访问次数
    ///   - priority: 优先级
    public init(
        timeWindow: TimeInterval = 1.0,
        maxCount: Int = 3,
        priority: Int = InterceptorPriority.highest
    ) {
        self.timeWindow = timeWindow
        self.maxCount = maxCount
        self.priority = priority
    }

    public func intercept(context: RouteContext, chain: InterceptorChain) {
        let key = context.pattern.isEmpty ? context.url : context.pattern
        let now = Date()

        lock.lock()
        defer { lock.unlock() }

        // 定期全量清理，防止内存泄漏
        if now.timeIntervalSince(lastCleanupTime) > cleanupInterval {
            performFullCleanup(now: now)
            lastCleanupTime = now
        }

        // 清理当前 key 的过期记录
        var records = accessRecords[key] ?? []
        records = records.filter { now.timeIntervalSince($0) < timeWindow }

        // 检查频率
        if records.count >= maxCount {
            chain.reject(reason: "Rate limit exceeded for '\(key)'")
            return
        }

        // 记录本次访问
        records.append(now)
        accessRecords[key] = records

        chain.proceed()
    }

    /// 全量清理过期记录
    private func performFullCleanup(now: Date) {
        var keysToRemove: [String] = []
        for (key, records) in accessRecords {
            let validRecords = records.filter { now.timeIntervalSince($0) < timeWindow }
            if validRecords.isEmpty {
                keysToRemove.append(key)
            } else {
                accessRecords[key] = validRecords
            }
        }
        for key in keysToRemove {
            accessRecords.removeValue(forKey: key)
        }
    }

    /// 重置频率限制
    public func reset() {
        lock.lock()
        accessRecords.removeAll()
        lastCleanupTime = Date()
        lock.unlock()
    }

    /// 获取当前记录的路由数量（用于调试）
    public var recordedRouteCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return accessRecords.count
    }
}
