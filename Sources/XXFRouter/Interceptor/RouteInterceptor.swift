//
//  RouteInterceptor.swift
//  XXFRouter
//
//  路由拦截器协议和实现
//  Created by XXF on 2024
//

import Foundation

// MARK: - 拦截结果

/// 拦截器处理结果
public enum InterceptorResult: Sendable {
    /// 继续执行，交给下一个拦截器或执行路由
    case proceed

    /// 继续执行，但使用修改后的上下文
    case proceedWith(RouteContext)

    /// 拦截，停止路由执行
    case reject(reason: String)

    /// 重定向到另一个URL
    case redirect(url: String)

    /// 异步处理，需要稍后调用completion
    case async
}

// MARK: - 拦截器优先级

/// 拦截器优先级预设值
public struct InterceptorPriority: Sendable {
    /// 最高优先级（首先执行）
    public static let highest: Int = 1000

    /// 高优先级
    public static let high: Int = 750

    /// 普通优先级
    public static let normal: Int = 500

    /// 低优先级
    public static let low: Int = 250

    /// 最低优先级（最后执行）
    public static let lowest: Int = 0
}

// MARK: - 拦截器协议

/// 路由拦截器协议
///
/// 拦截器用于在路由执行前进行检查和处理，例如：
/// - 登录状态检查
/// - 权限验证
/// - 参数校验
/// - 路由重定向
/// - 埋点统计
///
/// ## 同步拦截器示例：
/// ```swift
/// class SyncInterceptor: RouteInterceptor {
///     func intercept(context: RouteContext, chain: InterceptorChain) {
///         if someCondition {
///             chain.proceed()
///         } else {
///             chain.reject(reason: "条件不满足")
///         }
///     }
/// }
/// ```
///
/// ## 异步拦截器示例（网络请求、耗时操作）：
/// ```swift
/// class AsyncLoginInterceptor: RouteInterceptor {
///     var targetFlags: RouteFlags { .requiresLogin }
///
///     func intercept(context: RouteContext, chain: InterceptorChain) {
///         // 异步检查登录状态（例如：网络请求验证 token）
///         AuthService.shared.validateToken { result in
///             DispatchQueue.main.async {
///                 switch result {
///                 case .success:
///                     chain.proceed()
///                 case .failure:
///                     chain.redirect(to: "app://login")
///                 }
///             }
///         }
///         // 方法立即返回，拦截器链会等待 chain.proceed() 或 chain.reject() 被调用
///     }
/// }
/// ```
///
/// ## 使用 async/await 的异步拦截器：
/// ```swift
/// class ModernAsyncInterceptor: RouteInterceptor {
///     func intercept(context: RouteContext, chain: InterceptorChain) {
///         Task {
///             let isValid = await checkPermissionAsync()
///             await MainActor.run {
///                 if isValid {
///                     chain.proceed()
///                 } else {
///                     chain.reject(reason: "权限不足")
///                 }
///             }
///         }
///     }
/// }
/// ```
///
/// - Important: 无论同步还是异步，最终必须调用 `chain.proceed()`、`chain.reject()` 或 `chain.redirect()` 之一，
///   否则路由将永远挂起。
public protocol RouteInterceptor: AnyObject, Sendable {
    /// 拦截器名称，用于调试和日志
    var name: String { get }

    /// 拦截器优先级，数值越大越先执行
    var priority: Int { get }

    /// 目标标志位，只有匹配这些标志位的路由才会被拦截
    /// 返回空表示拦截所有路由
    var targetFlags: RouteFlags { get }

    /// 执行拦截
    /// - Parameters:
    ///   - context: 路由上下文
    ///   - chain: 拦截器链，用于传递控制权
    func intercept(context: RouteContext, chain: InterceptorChain)

    /// 判断是否应该拦截该路由
    /// - Parameter context: 路由上下文
    /// - Returns: 是否应该拦截
    func shouldIntercept(context: RouteContext) -> Bool
}

// MARK: - 默认实现

public extension RouteInterceptor {
    /// 默认名称为类名
    var name: String { String(describing: type(of: self)) }

    /// 默认普通优先级
    var priority: Int { InterceptorPriority.normal }

    /// 默认拦截所有路由
    var targetFlags: RouteFlags { .none }

    /// 默认根据targetFlags判断是否拦截
    func shouldIntercept(context: RouteContext) -> Bool {
        // 如果targetFlags为空，拦截所有路由
        if targetFlags.isEmpty {
            return true
        }
        // 否则检查路由的flags是否包含任何targetFlags
        return !context.flags.intersection(targetFlags).isEmpty
    }
}

// MARK: - 拦截器链

/// 拦截器链，管理拦截器的执行流程
public final class InterceptorChain: @unchecked Sendable {
    /// 拦截器列表
    private let interceptors: [RouteInterceptor]

    /// 当前执行位置
    private var currentIndex: Int = 0

    /// 路由上下文
    private var context: RouteContext

    /// 完成回调
    private let completion: @Sendable (InterceptorResult) -> Void

    /// 是否已完成
    private var isCompleted: Bool = false

    /// 锁（使用递归锁避免同步拦截器调用 proceed 时死锁）
    private let lock = NSRecursiveLock()

    /// 配置
    private let configuration: InterceptorChainConfiguration

    /// 超时任务
    private var timeoutTask: DispatchWorkItem?

    /// 创建拦截器链
    /// - Parameters:
    ///   - interceptors: 拦截器列表（已按优先级排序）
    ///   - context: 路由上下文
    ///   - configuration: 拦截器链配置
    ///   - completion: 完成回调
    init(
        interceptors: [RouteInterceptor],
        context: RouteContext,
        configuration: InterceptorChainConfiguration = .default,
        completion: @escaping @Sendable (InterceptorResult) -> Void
    ) {
        self.interceptors = interceptors
        self.context = context
        self.configuration = configuration
        self.completion = completion
    }

    /// 开始执行拦截器链
    func start() {
        // 设置超时
        if configuration.timeout > 0 {
            let task = DispatchWorkItem { [weak self] in
                self?.handleTimeout()
            }
            timeoutTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + configuration.timeout, execute: task)
        }

        processNext()
    }

    /// 处理超时
    private func handleTimeout() {
        lock.lock()
        guard !isCompleted else {
            lock.unlock()
            return
        }
        isCompleted = true
        lock.unlock()

        switch configuration.timeoutAction {
        case .reject(let reason):
            completion(.reject(reason: reason))
        case .proceed:
            completion(.proceedWith(context))
        }
    }

    /// 继续执行下一个拦截器
    /// - Parameter context: 更新后的上下文（可选）
    public func proceed(with context: RouteContext? = nil) {
        lock.lock()
        defer { lock.unlock() }

        guard !isCompleted else { return }

        if let newContext = context {
            self.context = newContext
        }

        currentIndex += 1
        processNext()
    }

    /// 拒绝路由
    /// - Parameter reason: 拒绝原因
    public func reject(reason: String) {
        complete(with: .reject(reason: reason))
    }

    /// 重定向到另一个URL
    /// - Parameter url: 目标URL
    public func redirect(to url: String) {
        complete(with: .redirect(url: url))
    }

    /// 处理下一个拦截器
    private func processNext() {
        // 查找下一个应该执行的拦截器
        while currentIndex < interceptors.count {
            let interceptor = interceptors[currentIndex]

            if interceptor.shouldIntercept(context: context) {
                interceptor.intercept(context: context, chain: self)
                return
            }

            currentIndex += 1
        }

        // 所有拦截器都已执行完毕
        complete(with: .proceed)
    }

    /// 完成拦截器链
    private func complete(with result: InterceptorResult) {
        lock.lock()
        guard !isCompleted else {
            lock.unlock()
            return
        }
        isCompleted = true

        // 取消超时任务
        timeoutTask?.cancel()
        timeoutTask = nil

        lock.unlock()

        // 根据结果类型传递最终上下文
        let finalResult: InterceptorResult
        switch result {
        case .proceed:
            finalResult = .proceedWith(context)
        case .proceedWith:
            finalResult = result
        default:
            finalResult = result
        }

        completion(finalResult)
    }
}

// MARK: - 拦截器管理器

/// 拦截器管理器，负责注册和管理所有拦截器
public final class InterceptorManager: @unchecked Sendable {
    /// 共享实例
    public static let shared = InterceptorManager()

    /// 读写锁
    private let lock = NSRecursiveLock()

    /// 注册的拦截器列表
    private var interceptors: [RouteInterceptor] = []

    /// 是否已排序
    private var isSorted: Bool = false

    /// 初始化
    public init() {}

    /// 注册拦截器
    /// - Parameter interceptor: 要注册的拦截器
    public func register(_ interceptor: RouteInterceptor) {
        lock.lock()
        defer { lock.unlock() }

        interceptors.append(interceptor)
        isSorted = false
    }

    /// 批量注册拦截器
    /// - Parameter interceptors: 拦截器数组
    public func register(_ interceptors: [RouteInterceptor]) {
        lock.lock()
        defer { lock.unlock() }

        self.interceptors.append(contentsOf: interceptors)
        isSorted = false
    }

    /// 移除拦截器
    /// - Parameter interceptor: 要移除的拦截器
    public func unregister(_ interceptor: RouteInterceptor) {
        lock.lock()
        defer { lock.unlock() }

        interceptors.removeAll { $0 === interceptor }
    }

    /// 移除所有拦截器
    public func clear() {
        lock.lock()
        defer { lock.unlock() }

        interceptors.removeAll()
        isSorted = false
    }

    /// 获取所有拦截器（按优先级排序）
    /// - Returns: 排序后的拦截器数组
    public func allInterceptors() -> [RouteInterceptor] {
        lock.lock()
        defer { lock.unlock() }

        if !isSorted {
            interceptors.sort { $0.priority > $1.priority }
            isSorted = true
        }

        return interceptors
    }

    /// 拦截器链配置
    public var chainConfiguration: InterceptorChainConfiguration = .default

    /// 创建拦截器链
    /// - Parameters:
    ///   - context: 路由上下文
    ///   - configuration: 拦截器链配置（可选，默认使用管理器的配置）
    ///   - completion: 完成回调
    /// - Returns: 拦截器链
    func createChain(
        for context: RouteContext,
        configuration: InterceptorChainConfiguration? = nil,
        completion: @escaping @Sendable (InterceptorResult) -> Void
    ) -> InterceptorChain {
        return InterceptorChain(
            interceptors: allInterceptors(),
            context: context,
            configuration: configuration ?? chainConfiguration,
            completion: completion
        )
    }

    /// 执行拦截器链
    /// - Parameters:
    ///   - context: 路由上下文
    ///   - configuration: 拦截器链配置（可选）
    ///   - completion: 完成回调
    public func intercept(
        context: RouteContext,
        configuration: InterceptorChainConfiguration? = nil,
        completion: @escaping @Sendable (InterceptorResult) -> Void
    ) {
        let chain = createChain(for: context, configuration: configuration, completion: completion)
        chain.start()
    }
}

// MARK: - 便捷拦截器

/// 全局拦截器基类，拦截所有路由
open class GlobalRouteInterceptor: RouteInterceptor, @unchecked Sendable {
    public init() {}

    open var name: String { String(describing: type(of: self)) }
    open var priority: Int { InterceptorPriority.normal }
    open var targetFlags: RouteFlags { .none }

    open func intercept(context: RouteContext, chain: InterceptorChain) {
        chain.proceed()
    }

    open func shouldIntercept(context: RouteContext) -> Bool {
        return true
    }
}

/// 标志位拦截器基类，只拦截具有特定标志位的路由
open class FlagBasedRouteInterceptor: RouteInterceptor, @unchecked Sendable {
    public let targetFlags: RouteFlags

    public init(targetFlags: RouteFlags) {
        self.targetFlags = targetFlags
    }

    open var name: String { String(describing: type(of: self)) }
    open var priority: Int { InterceptorPriority.normal }

    open func intercept(context: RouteContext, chain: InterceptorChain) {
        chain.proceed()
    }

    open func shouldIntercept(context: RouteContext) -> Bool {
        return !context.flags.intersection(targetFlags).isEmpty
    }
}

// MARK: - 闭包拦截器

// MARK: - 异步拦截器基类

/// 异步拦截器基类，提供更清晰的异步 API
///
/// 使用示例：
/// ```swift
/// class LoginInterceptor: AsyncRouteInterceptor {
///     override var targetFlags: RouteFlags { .requiresLogin }
///
///     override func interceptAsync(context: RouteContext) async -> InterceptorDecision {
///         do {
///             let isValid = try await AuthService.shared.validateToken()
///             if isValid {
///                 return .proceed
///             } else {
///                 return .redirect(to: "app://login")
///             }
///         } catch {
///             return .reject(reason: "认证失败: \(error.localizedDescription)")
///         }
///     }
/// }
/// ```
open class AsyncRouteInterceptor: RouteInterceptor, @unchecked Sendable {
    /// 拦截器决策
    public enum InterceptorDecision: Sendable {
        /// 继续执行
        case proceed
        /// 继续执行，使用修改后的上下文
        case proceedWith(RouteContext)
        /// 拒绝
        case reject(reason: String)
        /// 重定向
        case redirect(to: String)
    }

    public init() {}

    open var name: String { String(describing: type(of: self)) }
    open var priority: Int { InterceptorPriority.normal }
    open var targetFlags: RouteFlags { .none }

    /// 异步拦截方法，子类重写此方法
    /// - Parameter context: 路由上下文
    /// - Returns: 拦截决策
    open func interceptAsync(context: RouteContext) async -> InterceptorDecision {
        return .proceed
    }

    /// 实现同步接口，内部使用 Task 调用异步方法
    public func intercept(context: RouteContext, chain: InterceptorChain) {
        Task {
            let decision = await interceptAsync(context: context)
            await MainActor.run {
                switch decision {
                case .proceed:
                    chain.proceed()
                case .proceedWith(let newContext):
                    chain.proceed(with: newContext)
                case .reject(let reason):
                    chain.reject(reason: reason)
                case .redirect(let url):
                    chain.redirect(to: url)
                }
            }
        }
    }

    open func shouldIntercept(context: RouteContext) -> Bool {
        if targetFlags.isEmpty {
            return true
        }
        return !context.flags.intersection(targetFlags).isEmpty
    }
}

// MARK: - 带超时的拦截器链

/// 拦截器链配置
public struct InterceptorChainConfiguration: Sendable {
    /// 超时时间（秒），0 表示不超时
    public let timeout: TimeInterval

    /// 超时后的默认行为
    public let timeoutAction: TimeoutAction

    /// 超时行为
    public enum TimeoutAction: Sendable {
        /// 拒绝路由
        case reject(reason: String)
        /// 继续执行
        case proceed
    }

    /// 默认配置（30秒超时，超时后拒绝）
    public static let `default` = InterceptorChainConfiguration(
        timeout: 30,
        timeoutAction: .reject(reason: "Interceptor timeout")
    )

    /// 无超时配置
    public static let noTimeout = InterceptorChainConfiguration(
        timeout: 0,
        timeoutAction: .proceed
    )

    public init(timeout: TimeInterval, timeoutAction: TimeoutAction) {
        self.timeout = timeout
        self.timeoutAction = timeoutAction
    }
}

// MARK: - 闭包拦截器

/// 基于闭包的拦截器实现
public final class ClosureRouteInterceptor: RouteInterceptor, @unchecked Sendable {
    public let name: String
    public let priority: Int
    public let targetFlags: RouteFlags

    private let interceptBlock: @Sendable (RouteContext, InterceptorChain) -> Void
    private let shouldInterceptBlock: (@Sendable (RouteContext) -> Bool)?

    /// 创建闭包拦截器
    /// - Parameters:
    ///   - name: 拦截器名称
    ///   - priority: 优先级
    ///   - targetFlags: 目标标志位
    ///   - shouldIntercept: 判断是否应该拦截的闭包
    ///   - intercept: 执行拦截的闭包
    public init(
        name: String = "ClosureInterceptor",
        priority: Int = InterceptorPriority.normal,
        targetFlags: RouteFlags = .none,
        shouldIntercept: (@Sendable (RouteContext) -> Bool)? = nil,
        intercept: @escaping @Sendable (RouteContext, InterceptorChain) -> Void
    ) {
        self.name = name
        self.priority = priority
        self.targetFlags = targetFlags
        self.shouldInterceptBlock = shouldIntercept
        self.interceptBlock = intercept
    }

    public func intercept(context: RouteContext, chain: InterceptorChain) {
        interceptBlock(context, chain)
    }

    public func shouldIntercept(context: RouteContext) -> Bool {
        if let block = shouldInterceptBlock {
            return block(context)
        }

        if targetFlags.isEmpty {
            return true
        }

        return !context.flags.intersection(targetFlags).isEmpty
    }
}
