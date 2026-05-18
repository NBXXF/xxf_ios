//
//  RouteError.swift
//  XXFRouter
//
//  路由错误定义
//

/// 路由错误类型
public enum RouteError: Error, Sendable, CustomStringConvertible {
    /// 路由未找到（框架使用：是；场景：路由表未命中且降级未处理）
    case notFound(url: String)

    /// 被拦截器拦截（框架使用：否；场景：建议业务在需要结构化拦截错误时主动抛出）
    case intercepted(reason: String)

    /// 路由工厂抛出错误（框架使用：是；场景：factory 或 Routable init 抛出异常）
    case routeFactoryThrown(url: String, underlyingError: any Error)

    /// 导航失败（框架使用：是；场景：handler 返回 false 或导航器执行失败）
    case navigationFailed(reason: String)

    /// 服务未找到（框架使用：否；场景：业务侧 service 获取失败时主动抛出）
    case serviceNotFound(protocol: String)

    /// 无效的URL格式（框架使用：是；场景：外链降级处理器无法构建 URL）
    case invalidURL(url: String)

    /// 缺少必需参数（框架使用：否；场景：业务侧参数校验失败时主动抛出）
    case missingRequiredParameter(url: String, name: String)

    /// 参数类型错误（框架使用：否；场景：业务侧参数类型校验失败时主动抛出）
    case invalidParameterType(url: String, name: String, expected: String, actual: String)

    /// 自定义错误（框架使用：是；场景：超出最大重定向次数）
    case custom(url: String, code: Int, message: String)

    public var description: String {
        switch self {
        case .notFound(let url):
            return "Route not found: \(url)"
        case .intercepted(let reason):
            return "Route intercepted: \(reason)"
        case .routeFactoryThrown(let url, let underlyingError):
            return "Route factory threw error for '\(url)': \(underlyingError)"
        case .navigationFailed(let reason):
            return "Navigation failed: \(reason)"
        case .serviceNotFound(let proto):
            return "Service not found for protocol: \(proto)"
        case .invalidURL(let url):
            return "Invalid URL format: \(url)"
        case .missingRequiredParameter(let url, let name):
            return "Missing required parameter '\(name)' for URL: \(url)"
        case .invalidParameterType(let url, let name, let expected, let actual):
            return "Invalid parameter type for '\(name)' in URL '\(url)': expected \(expected), got \(actual)"
        case .custom(let url, let code, let message):
            return "Error(\(code)) for URL '\(url)': \(message)"
        }
    }
}
