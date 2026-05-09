//
//  Router.swift
//  XXFRouter
//
//  主路由器类，整合所有路由功能
//  Created by XXF on 2024
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 路由器配置

/// 路由器配置
public struct RouterConfiguration: Sendable {
    /// 是否启用拦截器
    public var interceptorEnabled: Bool

    /// 是否启用降级处理
    public var degradationEnabled: Bool

    /// 是否启用日志
    public var loggingEnabled: Bool

    /// 日志处理器
    public var logHandler: (@Sendable (String) -> Void)?

    /// 默认导航选项
    public var defaultNavigationOptions: RouteOptions

    /// 最大重定向次数（防止无限循环）
    public var maxRedirectCount: Int

    /// 创建默认配置
    public init(
        interceptorEnabled: Bool = true,
        degradationEnabled: Bool = true,
        loggingEnabled: Bool = false,
        logHandler: (@Sendable (String) -> Void)? = nil,
        defaultNavigationOptions: RouteOptions = .push,
        maxRedirectCount: Int = 5
    ) {
        self.interceptorEnabled = interceptorEnabled
        self.degradationEnabled = degradationEnabled
        self.loggingEnabled = loggingEnabled
        self.logHandler = logHandler
        self.defaultNavigationOptions = defaultNavigationOptions
        self.maxRedirectCount = maxRedirectCount
    }

    /// 默认配置
    public static let `default` = RouterConfiguration()

    /// 调试配置（启用日志）
    public static var debug: RouterConfiguration {
        var config = RouterConfiguration()
        config.loggingEnabled = true
        config.logHandler = { print($0) }
        return config
    }
}

// MARK: - 路由器

/// 主路由器类
///
/// XXFRouter 是一个功能完整的路由框架，提供以下特性：
/// - 基于URL的路由注册和导航
/// - 拦截器机制（支持登录检查、权限验证等）
/// - 服务发现（SPI机制）
/// - 降级策略
/// - 路由回调和监听
///
/// 使用示例：
/// ```swift
/// // 1. 注册路由
/// Router.shared.register(ProfileViewController.self)
/// Router.shared.register(pattern: "app://settings") { context in
///     return SettingsViewController()
/// }
///
/// // 2. 注册拦截器
/// Router.shared.registerInterceptor(LoginInterceptor())
///
/// // 3. 导航
/// Router.shared.navigate(to: "app://profile/123")
///
/// // 4. 带回调的导航
/// Router.shared.navigate(to: "app://profile/123") { result in
///     switch result {
///     case .success(let vc):
///         print("Success: \(vc)")
///     case .failure(let error):
///         print("Failed: \(error)")
///     }
/// }
/// ```
@MainActor
public final class Router: @unchecked Sendable {
    // MARK: - 单例

    /// 共享实例
    public static let shared = Router()

    // MARK: - 属性

    /// 路由配置
    public var configuration: RouterConfiguration {
        didSet {
            updateLogging()
        }
    }

    /// 路由注册表
    public let registry: RouteRegistry

    /// 拦截器管理器
    public let interceptorManager: InterceptorManager

    /// 服务注册表
    public let serviceRegistry: ServiceRegistry

    /// 降级管理器
    public let degradationManager: DegradationManager

    /// 监听器管理器
    public let listenerManager: RouteListenerManager

    /// 导航器
    public var navigator: RouteNavigator

    /// 日志监听器
    private var loggingListener: LoggingRouteListener?

    /// 锁
    private let lock = NSLock()

    // MARK: - 初始化

    /// 创建路由器实例
    /// - Parameter configuration: 路由配置
    public init(configuration: RouterConfiguration = .default) {
        self.configuration = configuration
        self.registry = RouteRegistry()
        self.interceptorManager = InterceptorManager()
        self.serviceRegistry = ServiceRegistry()
        self.degradationManager = DegradationManager()
        self.listenerManager = RouteListenerManager()
        self.navigator = DefaultRouteNavigator.shared

        updateLogging()
    }

    /// 更新日志配置
    private func updateLogging() {
        lock.lock()
        defer { lock.unlock() }

        // 移除旧的日志监听器
        if let listener = loggingListener {
            listenerManager.removeListener(listener)
            loggingListener = nil
        }

        // 如果启用日志，添加新的监听器
        if configuration.loggingEnabled {
            let handler = configuration.logHandler ?? { print($0) }
            let listener = LoggingRouteListener(logHandler: handler)
            listenerManager.addListener(listener)
            loggingListener = listener
        }
    }

    // MARK: - 路由注册

    /// 注册Routable类型
    /// - Parameter type: Routable类型
    public func register<T: Routable>(_ type: T.Type) {
        registry.register(type)
    }

    /// 注册闭包工厂
    /// - Parameters:
    ///   - pattern: 路由模式
    ///   - flags: 路由标志位
    ///   - priority: 优先级
    ///   - factory: 创建视图控制器的闭包。
    ///     业务可在此进行参数校验并抛出 RouteError，
    ///     例如 missingRequiredParameter / invalidParameterType / custom
    public func register(
        pattern: String,
        flags: RouteFlags = .none,
        priority: Int = 0,
        factory: @escaping @MainActor @Sendable (RouteContext) throws -> RouteViewController
    ) {
        registry.register(
            pattern: pattern,
            flags: flags,
            priority: priority,
            factory: factory
        )
    }

    /// 注册路由处理器
    /// - Parameters:
    ///   - pattern: 路由模式
    ///   - flags: 路由标志位
    ///   - priority: 优先级
    ///   - handler: 处理闭包
    public func registerHandler(
        pattern: String,
        flags: RouteFlags = .none,
        priority: Int = 0,
        handler: @escaping @Sendable (RouteContext) -> Bool
    ) {
        registry.registerHandler(
            pattern: pattern,
            flags: flags,
            priority: priority,
            handler: handler
        )
    }

    /// 批量注册（使用构建器）
    /// - Parameter builder: 注册构建器闭包
    public func register(_ builder: (RouteRegistryBuilder) -> Void) {
        registry.register(builder)
    }

    /// 批量注册 Routable 类型（高效版本，一次锁操作完成所有注册）
    /// - Parameter types: Routable 类型数组
    ///
    /// 使用示例：
    /// ```swift
    /// router.register([
    ///     HomeViewController.self,
    ///     ProfileViewController.self,
    ///     SettingsViewController.self
    /// ])
    /// ```
    public func register(_ types: [any Routable.Type]) {
        registry.register(types)
    }

    /// 批量注册闭包工厂（高效版本，一次锁操作完成所有注册）
    /// - Parameter factories: 工厂配置数组
    ///
    /// 使用示例：
    /// ```swift
    /// router.register(factories: [
    ///     RouteFactoryConfig(pattern: "app://home") { _ in HomeVC() },
    ///     RouteFactoryConfig(pattern: "app://profile/<userId>", flags: .requiresLogin) { ctx in
    ///         ProfileVC(userId: ctx.string(for: "userId") ?? "")
    ///     }
    /// ])
    /// ```
    public func register(factories: [RouteFactoryConfig]) {
        registry.register(factories: factories)
    }

    /// 批量注册处理器（高效版本，一次锁操作完成所有注册）
    /// - Parameter handlers: 处理器配置数组
    ///
    /// 使用示例：
    /// ```swift
    /// router.register(handlers: [
    ///     RouteHandlerConfig(pattern: "app://logout") { _ in
    ///         AuthService.shared.logout()
    ///         return true
    ///     },
    ///     RouteHandlerConfig(pattern: "app://share") { ctx in
    ///         ShareManager.share(content: ctx.string(for: "content"))
    ///         return true
    ///     }
    /// ])
    /// ```
    public func register(handlers: [RouteHandlerConfig]) {
        registry.register(handlers: handlers)
    }

    // MARK: - 拦截器

    /// 注册拦截器
    /// - Parameter interceptor: 拦截器
    public func registerInterceptor(_ interceptor: RouteInterceptor) {
        interceptorManager.register(interceptor)
    }

    /// 注册闭包拦截器
    /// - Parameters:
    ///   - name: 拦截器名称
    ///   - priority: 优先级
    ///   - targetFlags: 目标标志位
    ///   - intercept: 拦截处理闭包
    public func registerInterceptor(
        name: String = "ClosureInterceptor",
        priority: Int = InterceptorPriority.normal,
        targetFlags: RouteFlags = .none,
        intercept: @escaping @Sendable (RouteContext, InterceptorChain) -> Void
    ) {
        let interceptor = ClosureRouteInterceptor(
            name: name,
            priority: priority,
            targetFlags: targetFlags,
            intercept: intercept
        )
        interceptorManager.register(interceptor)
    }

    // MARK: - 服务注册

    /// 注册服务
    /// - Parameters:
    ///   - implementation: 服务实现类型
    ///   - protocol: 服务协议类型
    public func registerService<Implementation: ServiceProtocol, Protocol>(
        _ implementation: Implementation.Type,
        for protocol: Protocol.Type
    ) {
        serviceRegistry.register(implementation, for: `protocol`)
    }

    /// 获取服务
    /// - Parameter protocol: 服务协议类型
    /// - Returns: 服务实例
    public func service<Protocol>(for protocol: Protocol.Type = Protocol.self) -> Protocol? {
        return serviceRegistry.service(for: `protocol`)
    }

    // MARK: - 降级处理

    /// 注册降级处理器
    /// - Parameter handler: 降级处理器
    public func registerDegradation(_ handler: DegradationHandler) {
        degradationManager.register(handler)
    }

    /// 设置默认降级处理器
    /// - Parameter handler: 默认处理器
    public func setDefaultDegradation(_ handler: DegradationHandler) {
        degradationManager.setDefault(handler)
    }

    /// 设置404页面工厂
    /// - Parameter factory: 创建404页面的闭包
    public func setNotFoundPage(_ factory: @escaping @Sendable (RouteContext) -> RouteViewController) {
        let handler = NotFoundDegradationHandler(pageFactory: factory)
        degradationManager.setDefault(handler)
    }

    // MARK: - 监听器

    /// 添加路由监听器
    /// - Parameter listener: 监听器
    public func addListener(_ listener: RouteListener) {
        listenerManager.addListener(listener)
    }

    /// 移除路由监听器
    /// - Parameter listener: 监听器
    public func removeListener(_ listener: RouteListener) {
        listenerManager.removeListener(listener)
    }

    // MARK: - 导航方法

    /// 导航到指定URL
    /// - Parameters:
    ///   - url: 目标URL
    ///   - extraParameters: 额外参数
    ///   - options: 导航选项
    ///   - from: 来源视图控制器
    ///   - callback: 路由回调
    public func navigate(
        to url: String,
        extraParameters: RouteParameters = [:],
        options: RouteOptions? = nil,
        from sourceViewController: RouteViewController? = nil,
        callback: RouteCallback? = nil
    ) {
        performNavigation(
            url: url,
            extraParameters: extraParameters,
            options: options ?? configuration.defaultNavigationOptions,
            sourceViewController: sourceViewController,
            callback: callback,
            redirectCount: 0
        )
    }

    /// 导航到指定URL（带完成回调）
    /// - Parameters:
    ///   - url: 目标URL
    ///   - extraParameters: 额外参数
    ///   - options: 导航选项
    ///   - from: 来源视图控制器
    ///   - completion: 完成回调
    public func navigate(
        to url: String,
        extraParameters: RouteParameters = [:],
        options: RouteOptions? = nil,
        from sourceViewController: RouteViewController? = nil,
        completion: (@Sendable (RouteResult) -> Void)?
    ) {
        let callback = ClosureRouteCallback(onComplete: { _, result in
            completion?(result)
        })

        navigate(
            to: url,
            extraParameters: extraParameters,
            options: options,
            from: sourceViewController,
            callback: callback
        )
    }

    /// 检查URL是否可以路由
    /// - Parameter url: URL字符串
    /// - Returns: 是否可以路由
    public func canRoute(to url: String) -> Bool {
        return registry.contains(url: url)
    }

    /// 获取URL对应的视图控制器（不执行导航）
    /// - Parameters:
    ///   - url: URL字符串
    ///   - extraParameters: 额外参数
    /// - Returns: 视图控制器
    public func viewController(
        for url: String,
        extraParameters: RouteParameters = [:]
    ) -> RouteViewController? {
        guard let (entry, pathParameters) = registry.find(for: url) else {
            return nil
        }

        guard let factory = entry.factory else {
            return nil
        }

        let queryParameters = parseQueryParameters(from: url)
        let context = RouteContext(
            url: url,
            pattern: entry.pattern,
            pathParameters: pathParameters,
            queryParameters: queryParameters,
            extraParameters: extraParameters,
            flags: entry.flags
        )

        return try? factory.createViewController(with: context)
    }

    // MARK: - 内部导航实现

    private func performNavigation(
        url: String,
        extraParameters: RouteParameters,
        options: RouteOptions,
        sourceViewController: RouteViewController?,
        callback: RouteCallback?,
        redirectCount: Int
    ) {
        // 检查重定向次数
        guard redirectCount < configuration.maxRedirectCount else {
            let error = RouteError.custom(url: url, code: -1, message: "Too many redirects")
            callback?.onRouteFailure(context: RouteContext(url: url), error: error)
            callback?.onRouteComplete(context: RouteContext(url: url), result: .failure(error: error))
            return
        }

        // 解析URL
        let queryParameters = parseQueryParameters(from: url)

        // 查找路由
        let findResult = registry.find(for: url)

        // 创建上下文
        let context = RouteContext(
            url: url,
            pattern: findResult?.entry.pattern ?? "",
            pathParameters: findResult?.parameters ?? [:],
            queryParameters: queryParameters,
            extraParameters: extraParameters,
            flags: findResult?.entry.flags ?? .none,
            sourceViewController: sourceViewController
        )

        // 通知开始
        callback?.onRouteStart(context: context)
        listenerManager.notify(event: .start, context: context)

        // 执行拦截器
        if configuration.interceptorEnabled {
            // 保存需要在闭包中使用的值（使用 Sendable 类型）
            let entryPattern = findResult?.entry.pattern
            let entryFlags = findResult?.entry.flags
            let entryFactory = findResult?.entry.factory
            let entryHandler = findResult?.entry.handler
            let entryPriority = findResult?.entry.priority

            // 将路径参数转换为可发送的字符串字典
            let sendableParams: [String: String] = {
                var dict: [String: String] = [:]
                if let params = findResult?.parameters {
                    for (key, value) in params {
                        dict[key] = String(describing: value)
                    }
                }
                return dict
            }()

            // 保存原始上下文信息用于后续恢复
            let originalURL = url
            let originalQueryParams = queryParameters

            // 将额外参数转换为可发送的字符串字典
            let sendableExtraParams: [String: String] = {
                var dict: [String: String] = [:]
                for (key, value) in extraParameters {
                    dict[key] = String(describing: value)
                }
                return dict
            }()

            interceptorManager.intercept(context: context) { [weak self] result in
                Task { @MainActor in
                    // 重建 findResult
                    var reconstructedEntry: RouteEntry?
                    if let pattern = entryPattern {
                        reconstructedEntry = RouteEntry(
                            pattern: pattern,
                            flags: entryFlags ?? .none,
                            priority: entryPriority ?? 0,
                            factory: entryFactory,
                            handler: entryHandler
                        )
                    }

                    // 将字符串字典转换回 RouteParameters
                    var pathParams: RouteParameters = [:]
                    for (key, value) in sendableParams {
                        pathParams[key] = value
                    }

                    // 将额外参数转换回 RouteParameters
                    var extraParams: RouteParameters = [:]
                    for (key, value) in sendableExtraParams {
                        extraParams[key] = value
                    }

                    let reconstructedFindResult: (entry: RouteEntry, parameters: RouteParameters)?
                    if let entry = reconstructedEntry {
                        reconstructedFindResult = (entry, pathParams)
                    } else {
                        reconstructedFindResult = nil
                    }

                    // 重建原始上下文
                    let originalContext = RouteContext(
                        url: originalURL,
                        pattern: entryPattern ?? "",
                        pathParameters: pathParams,
                        queryParameters: originalQueryParams,
                        extraParameters: extraParams,
                        flags: entryFlags ?? .none,
                        sourceViewController: sourceViewController
                    )

                    self?.handleInterceptorResult(
                        result: result,
                        originalContext: originalContext,
                        findResult: reconstructedFindResult,
                        options: options,
                        callback: callback,
                        redirectCount: redirectCount
                    )
                }
            }
        } else {
            // 跳过拦截器
            executeRoute(
                context: context,
                entry: findResult?.entry,
                options: options,
                callback: callback,
                redirectCount: redirectCount
            )
        }
    }

    private func handleInterceptorResult(
        result: InterceptorResult,
        originalContext: RouteContext,
        findResult: (entry: RouteEntry, parameters: RouteParameters)?,
        options: RouteOptions,
        callback: RouteCallback?,
        redirectCount: Int
    ) {
        switch result {
        case .proceed:
            // 使用原始上下文继续
            if let entry = findResult?.entry {
                executeRoute(
                    context: originalContext,
                    entry: entry,
                    options: options,
                    callback: callback,
                    redirectCount: redirectCount
                )
            } else {
                handleRouteNotFound(
                    context: originalContext,
                    options: options,
                    callback: callback,
                    redirectCount: redirectCount
                )
            }

        case .proceedWith(let updatedContext):
            // 使用更新后的上下文继续
            executeRoute(
                context: updatedContext,
                entry: findResult?.entry,
                options: options,
                callback: callback,
                redirectCount: redirectCount
            )

        case .reject(let reason):
            // 被拦截，使用原始上下文
            callback?.onRouteIntercepted(context: originalContext, reason: reason)
            listenerManager.notify(event: .intercepted(reason: reason), context: originalContext)
            callback?.onRouteComplete(context: originalContext, result: .intercepted(reason: reason))

        case .redirect(let targetURL):
            // 重定向，保留原始的额外参数
            performNavigation(
                url: targetURL,
                extraParameters: originalContext.extraParameters,
                options: options,
                sourceViewController: originalContext.sourceViewController,
                callback: callback,
                redirectCount: redirectCount + 1
            )

        case .async:
            // 异步处理，等待拦截器调用chain.proceed()或chain.reject()
            break
        }
    }

    private func executeRoute(
        context: RouteContext,
        entry: RouteEntry?,
        options: RouteOptions,
        callback: RouteCallback?,
        redirectCount: Int
    ) {
        guard let entry = entry else {
            handleRouteNotFound(
                context: context,
                options: options,
                callback: callback,
                redirectCount: redirectCount
            )
            return
        }

        // 处理器路由
        if let handler = entry.handler {
            let success = handler.handle(context: context)
            listenerManager.notify(event: .handlerExecuted(success: success), context: context)

            if success {
                callback?.onRouteSuccess(context: context, viewController: nil)
                callback?.onRouteComplete(context: context, result: .handled)
            } else {
                let error = RouteError.navigationFailed(reason: "Handler returned false")
                callback?.onRouteFailure(context: context, error: error)
                callback?.onRouteComplete(context: context, result: .failure(error: error))
            }
            return
        }

        // 工厂路由
        guard let factory = entry.factory else {
            handleRouteNotFound(
                context: context,
                options: options,
                callback: callback,
                redirectCount: redirectCount
            )
            return
        }

        // 创建视图控制器
        let viewController: RouteViewController
        do {
            viewController = try factory.createViewController(with: context)
        } catch let routeError as RouteError {
            callback?.onRouteFailure(context: context, error: routeError)
            callback?.onRouteComplete(context: context, result: .failure(error: routeError))
            return
        } catch {
            let routeError = RouteError.routeFactoryThrown(url: context.url, underlyingError: error)
            callback?.onRouteFailure(context: context, error: routeError)
            callback?.onRouteComplete(context: context, result: .failure(error: routeError))
            return
        }

        listenerManager.notify(event: .viewControllerCreated(viewController), context: context)
        listenerManager.notify(event: .navigationStart, context: context)

        // 执行导航
        navigator.navigate(to: viewController, context: context, options: options) { [weak self] success in
            if success {
                self?.listenerManager.notify(event: .navigationComplete, context: context)
                self?.listenerManager.notify(event: .success, context: context)
                callback?.onRouteSuccess(context: context, viewController: viewController)
                callback?.onRouteComplete(context: context, result: .success(viewController: viewController))
            } else {
                let error = RouteError.navigationFailed(reason: "Navigation failed")
                self?.listenerManager.notify(event: .failure(error), context: context)
                callback?.onRouteFailure(context: context, error: error)
                callback?.onRouteComplete(context: context, result: .failure(error: error))
            }
        }
    }

    private func handleRouteNotFound(
        context: RouteContext,
        options: RouteOptions,
        callback: RouteCallback?,
        redirectCount: Int
    ) {
        listenerManager.notify(event: .notFound, context: context)
        callback?.onRouteNotFound(context: context)

        // 降级处理
        if configuration.degradationEnabled {
            let degradationResult = degradationManager.handle(context: context)

            switch degradationResult {
            case .viewController(let vc):
                listenerManager.notify(event: .degraded, context: context)
                navigator.navigate(to: vc, context: context, options: options) { [weak self] success in
                    if success {
                        callback?.onRouteComplete(context: context, result: .degraded(viewController: vc))
                    } else {
                        let error = RouteError.navigationFailed(reason: "Degradation navigation failed")
                        self?.listenerManager.notify(event: .failure(error), context: context)
                        callback?.onRouteComplete(context: context, result: .failure(error: error))
                    }
                }

            case .redirect(let targetURL):
                performNavigation(
                    url: targetURL,
                    extraParameters: [:],
                    options: options,
                    sourceViewController: nil,
                    callback: callback,
                    redirectCount: redirectCount + 1
                )

            case .handled:
                listenerManager.notify(event: .degraded, context: context)
                callback?.onRouteComplete(context: context, result: .degraded(viewController: nil))

            case .continue, .failure:
                let error = RouteError.notFound(url: context.url)
                listenerManager.notify(event: .failure(error), context: context)
                callback?.onRouteFailure(context: context, error: error)
                callback?.onRouteComplete(context: context, result: .failure(error: error))
            }
        } else {
            let error = RouteError.notFound(url: context.url)
            listenerManager.notify(event: .failure(error), context: context)
            callback?.onRouteFailure(context: context, error: error)
            callback?.onRouteComplete(context: context, result: .failure(error: error))
        }
    }

    // MARK: - 辅助方法

    private func parseQueryParameters(from url: String) -> RouteQueryItems {
        guard let components = URLComponents(string: url),
              let queryItems = components.queryItems else {
            return [:]
        }

        var parameters: RouteQueryItems = [:]
        for item in queryItems {
            parameters[item.name] = item.value ?? ""
        }
        return parameters
    }
}

// MARK: - 便捷方法扩展

public extension Router {
    /// 使用链式API配置路由器
    @discardableResult
    func configure(_ configuration: (inout RouterConfiguration) -> Void) -> Self {
        var config = self.configuration
        configuration(&config)
        self.configuration = config
        return self
    }

    /// Push导航
    func push(
        to url: String,
        extraParameters: RouteParameters = [:],
        from sourceViewController: RouteViewController? = nil,
        animated: Bool = true,
        completion: (@Sendable (RouteResult) -> Void)? = nil
    ) {
        var options = RouteOptions.push
        options.animated = animated

        navigate(
            to: url,
            extraParameters: extraParameters,
            options: options,
            from: sourceViewController,
            completion: completion
        )
    }

    /// Present导航
    func present(
        to url: String,
        extraParameters: RouteParameters = [:],
        from sourceViewController: RouteViewController? = nil,
        animated: Bool = true,
        completion: (@Sendable (RouteResult) -> Void)? = nil
    ) {
        var options = RouteOptions.present
        options.animated = animated

        navigate(
            to: url,
            extraParameters: extraParameters,
            options: options,
            from: sourceViewController,
            completion: completion
        )
    }

    /// 执行路由处理器（不进行导航）
    @discardableResult
    func handle(
        url: String,
        extraParameters: RouteParameters = [:]
    ) -> Bool {
        guard let (entry, pathParameters) = registry.find(for: url) else {
            return false
        }

        guard let handler = entry.handler else {
            return false
        }

        var queryParams: RouteQueryItems = [:]
        if let components = URLComponents(string: url),
           let queryItems = components.queryItems {
            for item in queryItems {
                queryParams[item.name] = item.value ?? ""
            }
        }

        let context = RouteContext(
            url: url,
            pattern: entry.pattern,
            pathParameters: pathParameters,
            queryParameters: queryParams,
            extraParameters: extraParameters,
            flags: entry.flags
        )

        return handler.handle(context: context)
    }
}

// MARK: - Async/Await 支持

public extension Router {
    /// 异步导航到指定URL
    /// - Parameters:
    ///   - url: 目标URL
    ///   - extraParameters: 额外参数
    ///   - options: 导航选项
    ///   - from: 来源视图控制器
    /// - Returns: 路由结果
    func navigate(
        to url: String,
        extraParameters: RouteParameters = [:],
        options: RouteOptions? = nil,
        from sourceViewController: RouteViewController? = nil
    ) async -> RouteResult {
        await withCheckedContinuation { continuation in
            navigate(
                to: url,
                extraParameters: extraParameters,
                options: options,
                from: sourceViewController
            ) { result in
                continuation.resume(returning: result)
            }
        }
    }

    /// 异步 Push 导航
    func push(
        to url: String,
        extraParameters: RouteParameters = [:],
        from sourceViewController: RouteViewController? = nil,
        animated: Bool = true
    ) async -> RouteResult {
        await withCheckedContinuation { continuation in
            push(
                to: url,
                extraParameters: extraParameters,
                from: sourceViewController,
                animated: animated
            ) { result in
                continuation.resume(returning: result)
            }
        }
    }

    /// 异步 Present 导航
    func present(
        to url: String,
        extraParameters: RouteParameters = [:],
        from sourceViewController: RouteViewController? = nil,
        animated: Bool = true
    ) async -> RouteResult {
        await withCheckedContinuation { continuation in
            present(
                to: url,
                extraParameters: extraParameters,
                from: sourceViewController,
                animated: animated
            ) { result in
                continuation.resume(returning: result)
            }
        }
    }
}

// MARK: - 防抖导航

/// 防抖导航管理器，防止短时间内重复点击导致多次导航
@MainActor
public final class DebounceNavigator: @unchecked Sendable {
    /// 共享实例
    public static let shared = DebounceNavigator()

    /// 防抖间隔（秒）
    public var debounceInterval: TimeInterval = 0.5

    /// 上次导航时间和 URL
    private var lastNavigationTime: Date = .distantPast
    private var lastNavigationURL: String = ""
    private let lock = NSLock()

    private init() {}

    /// 检查是否应该允许导航
    /// - Parameter url: 目标 URL
    /// - Returns: 是否允许导航
    public func shouldAllowNavigation(to url: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        let now = Date()
        let timeSinceLastNavigation = now.timeIntervalSince(lastNavigationTime)

        // 如果是同一个 URL 且在防抖间隔内，拒绝导航
        if url == lastNavigationURL && timeSinceLastNavigation < debounceInterval {
            return false
        }

        // 更新记录
        lastNavigationTime = now
        lastNavigationURL = url
        return true
    }

    /// 重置防抖状态
    public func reset() {
        lock.lock()
        lastNavigationTime = .distantPast
        lastNavigationURL = ""
        lock.unlock()
    }
}

public extension Router {
    /// 带防抖的导航（防止重复点击）
    /// - Parameters:
    ///   - url: 目标URL
    ///   - extraParameters: 额外参数
    ///   - options: 导航选项
    ///   - from: 来源视图控制器
    ///   - completion: 完成回调
    func navigateWithDebounce(
        to url: String,
        extraParameters: RouteParameters = [:],
        options: RouteOptions? = nil,
        from sourceViewController: RouteViewController? = nil,
        completion: (@Sendable (RouteResult) -> Void)? = nil
    ) {
        guard DebounceNavigator.shared.shouldAllowNavigation(to: url) else {
            // 被防抖拦截
            completion?(.intercepted(reason: "Navigation debounced"))
            return
        }

        navigate(
            to: url,
            extraParameters: extraParameters,
            options: options,
            from: sourceViewController,
            completion: completion
        )
    }
}
