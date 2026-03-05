//
//  CachingRxCallAdapter.swift
//  xxf_ios
//
//  RxSwift 缓存请求适配器
//
//  功能说明:
//  根据 RestApiService 配置的缓存策略自动处理缓存逻辑。
//  支持多种缓存策略，每种策略有不同的缓存读写和发射行为。
//  支持业务自定义 HttpCache 实例，实现缓存隔离。
//
//  缓存策略:
//  ┌─────────────┬────────────────────────────────────────────────┐
//  │ 策略         │ 行为                                           │
//  ├─────────────┼────────────────────────────────────────────────┤
//  │ onlyRemote  │ 只走网络，不使用缓存                             │
//  │ firstCache  │ 先返回缓存，再请求网络（可能发射 1-2 次）         │
//  │ firstRemote │ 先请求网络，失败时回退缓存                        │
//  │ onlyCache   │ 只读缓存，没有则 empty                           │
//  │ ifCache     │ 有缓存用缓存，无缓存走网络                        │
//  │ lastCache   │ 返回缓存后静默更新网络（有缓存时只发射一次）       │
//  └─────────────┴────────────────────────────────────────────────┘
//
//  缓存实例选择:
//  - 默认使用 HttpCache.shared 全局实例
//  - 业务可通过 RestApiService.httpCache 属性自定义缓存实例
//  - 自定义实例实现缓存隔离，避免不同业务间缓存冲突
//
//  线程安全:
//  - 使用 HttpCache 的线程安全保证
//  - Observable 操作符保证订阅安全
//  - 缓存数据在回调线程发射，由订阅者通过 observe(on:) 决定接收线程
//
//  Created by xxf on 2025/3/4.
//

import Foundation
@preconcurrency import Moya
@preconcurrency import RxSwift

// MARK: - 线程安全状态管理

/// 缓存状态管理器（线程安全）
///
/// 用于在并发环境中安全地管理缓存发射状态
private final class CacheState: @unchecked Sendable {
    private let lock = NSLock()
    private var _hasCacheEmitted = false
    private var _hasNetworkEmitted = false

    var hasCacheEmitted: Bool {
        get { lock.withLock { _hasCacheEmitted } }
        set { lock.withLock { _hasCacheEmitted = newValue } }
    }

    var hasNetworkEmitted: Bool {
        get { lock.withLock { _hasNetworkEmitted } }
        set { lock.withLock { _hasNetworkEmitted = newValue } }
    }

    /// 原子性检查并设置缓存发射状态
    /// - Returns: 是否应该发射（之前未发射过）
    func tryEmitCache() -> Bool {
        lock.withLock {
            if !_hasCacheEmitted && !_hasNetworkEmitted {
                _hasCacheEmitted = true
                return true
            }
            return false
        }
    }

    /// 原子性检查并设置网络发射状态
    /// - Returns: 缓存是否已发射
    func markNetworkEmitted() -> Bool {
        lock.withLock {
            _hasNetworkEmitted = true
            return _hasCacheEmitted
        }
    }

    /// 原子性尝试发射（用于只发射一次的场景）
    /// - Returns: 是否应该发射
    func tryEmitOnce() -> Bool {
        lock.withLock {
            if !_hasCacheEmitted && !_hasNetworkEmitted {
                _hasCacheEmitted = true
                return true
            }
            return false
        }
    }
}

/// 线程安全的 Observer 包装器
///
/// 将 AnyObserver 包装为 Sendable 类型，用于在并发闭包中安全使用
private final class SendableObserver<Element>: @unchecked Sendable {
    private let observer: AnyObserver<Element>

    init(_ observer: AnyObserver<Element>) {
        self.observer = observer
    }

    func onNext(_ element: Element) {
        observer.onNext(element)
    }

    func onError(_ error: Error) {
        observer.onError(error)
    }

    func onCompleted() {
        observer.onCompleted()
    }
}

// MARK: - FirstCache 协调器

/// firstCache 策略的协调器
///
/// 核心职责：确保磁盘缓存检查完成后，才发射网络响应
/// 这解决了磁盘缓存读取慢导致缓存和网络响应几乎同时到达的问题
///
/// 工作流程：
/// 1. 磁盘缓存检查和网络请求并行执行
/// 2. 如果网络响应先到，缓冲它，等待磁盘检查完成
/// 3. 磁盘检查完成后：
///    - 如果有缓存，先发射缓存
///    - 然后发射缓冲的网络响应（或等待网络响应）
private final class FirstCacheCoordinator: @unchecked Sendable {
    private let lock = NSLock()
    private let observer: AnyObserver<Response>

    // 状态
    private var diskCheckCompleted = false
    private var cacheEmitted = false
    private var disposed = false

    // 缓冲的网络响应
    private var pendingNetworkResponse: Response?
    private var pendingNetworkError: Error?
    private var networkCompleted = false

    init(observer: AnyObserver<Response>) {
        self.observer = observer
    }

    /// 磁盘缓存检查完成回调
    func onDiskCacheResult(_ cached: Response?) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        diskCheckCompleted = true

        // 如果有磁盘缓存，先发射
        if let cached = cached {
            cacheEmitted = true
            observer.onNext(cached)
        }

        // 处理缓冲的网络响应
        flushPendingNetworkEvents()
    }

    /// 网络响应回调
    func onNetworkResponse(_ response: Response) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        if diskCheckCompleted {
            // 磁盘检查已完成，直接发射
            observer.onNext(response)
        } else {
            // 磁盘检查未完成，缓冲响应
            pendingNetworkResponse = response
        }
    }

    /// 网络错误回调
    func onNetworkError(_ error: Error) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        if diskCheckCompleted {
            // 磁盘检查已完成
            if cacheEmitted {
                // 有缓存已发射，忽略错误，正常完成
                observer.onCompleted()
            } else {
                // 没有缓存，传递错误
                observer.onError(error)
            }
        } else {
            // 磁盘检查未完成，缓冲错误
            pendingNetworkError = error
        }
    }

    /// 网络完成回调
    func onNetworkCompleted() {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        networkCompleted = true

        if diskCheckCompleted {
            observer.onCompleted()
        }
        // 如果磁盘检查未完成，完成事件会在 flushPendingNetworkEvents 中处理
    }

    /// 释放资源
    func dispose() {
        lock.lock()
        disposed = true
        lock.unlock()
    }

    /// 刷新缓冲的网络事件（在锁内调用）
    private func flushPendingNetworkEvents() {
        // 发射缓冲的网络响应
        if let response = pendingNetworkResponse {
            pendingNetworkResponse = nil
            observer.onNext(response)
        }

        // 处理缓冲的错误
        if let error = pendingNetworkError {
            pendingNetworkError = nil
            if cacheEmitted {
                observer.onCompleted()
            } else {
                observer.onError(error)
            }
            return
        }

        // 处理完成事件
        if networkCompleted {
            observer.onCompleted()
        }
    }
}

// MARK: - IfCache 协调器

/// ifCache 策略的协调器
///
/// 核心职责：等磁盘检查完成后，决定使用缓存还是网络响应
/// - 有缓存：发射缓存，忽略网络
/// - 无缓存：发射网络响应
private final class IfCacheCoordinator: @unchecked Sendable {
    private let lock = NSLock()
    private let observer: AnyObserver<Response>

    // 状态
    private var diskCheckCompleted = false
    private var emitted = false
    private var disposed = false

    // 缓冲的网络响应
    private var pendingNetworkResponse: Response?
    private var pendingNetworkError: Error?

    init(observer: AnyObserver<Response>) {
        self.observer = observer
    }

    /// 磁盘缓存检查完成回调
    func onDiskCacheResult(_ cached: Response?) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed, !emitted else { return }

        diskCheckCompleted = true

        // 如果有磁盘缓存，发射缓存并完成
        if let cached = cached {
            emitted = true
            observer.onNext(cached)
            observer.onCompleted()
            return
        }

        // 无缓存，处理等待中的网络响应
        if let response = pendingNetworkResponse {
            emitted = true
            observer.onNext(response)
            observer.onCompleted()
        } else if let error = pendingNetworkError {
            emitted = true
            observer.onError(error)
        }
    }

    /// 网络响应回调
    func onNetworkResponse(_ response: Response) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed, !emitted else { return }

        if diskCheckCompleted {
            // 磁盘检查已完成且无缓存，发射网络响应
            emitted = true
            observer.onNext(response)
            observer.onCompleted()
        } else {
            // 磁盘检查未完成，缓冲响应
            pendingNetworkResponse = response
        }
    }

    /// 网络错误回调
    func onNetworkError(_ error: Error) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed, !emitted else { return }

        if diskCheckCompleted {
            // 磁盘检查已完成且无缓存，传递错误
            emitted = true
            observer.onError(error)
        } else {
            pendingNetworkError = error
        }
    }

    /// 网络完成回调（ifCache 模式下网络完成后无特殊处理）
    func onNetworkCompleted() {
        // ifCache 只发射一次，网络完成时要么已经发射了，要么等磁盘检查
    }

    func dispose() {
        lock.lock()
        disposed = true
        lock.unlock()
    }
}

// MARK: - LastCache 协调器

/// lastCache 策略的协调器
///
/// 核心职责：等磁盘检查完成后，决定使用缓存还是网络响应（只发射一次）
/// - 有缓存：发射缓存，静默更新网络（不再发射）
/// - 无缓存：发射网络响应
private final class LastCacheCoordinator: @unchecked Sendable {
    private let lock = NSLock()
    private let observer: AnyObserver<Response>

    // 状态
    private var diskCheckCompleted = false
    private var cacheEmitted = false
    private var disposed = false

    // 缓冲的网络响应
    private var pendingNetworkResponse: Response?
    private var pendingNetworkError: Error?
    private var networkCompleted = false

    init(observer: AnyObserver<Response>) {
        self.observer = observer
    }

    /// 磁盘缓存检查完成回调
    func onDiskCacheResult(_ cached: Response?) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        diskCheckCompleted = true

        // 如果有磁盘缓存，发射缓存
        if let cached = cached {
            cacheEmitted = true
            observer.onNext(cached)
            // 等待网络完成后再 complete
            if networkCompleted {
                observer.onCompleted()
            }
            return
        }

        // 无缓存，处理等待中的网络响应
        if let response = pendingNetworkResponse {
            observer.onNext(response)
            if networkCompleted {
                observer.onCompleted()
            }
        } else if let error = pendingNetworkError {
            observer.onError(error)
        } else if networkCompleted {
            observer.onCompleted()
        }
    }

    /// 网络响应回调
    func onNetworkResponse(_ response: Response) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        if diskCheckCompleted {
            // 磁盘检查已完成
            if !cacheEmitted {
                // 无缓存，发射网络响应
                observer.onNext(response)
            }
            // 有缓存时，静默更新（不发射）
        } else {
            // 磁盘检查未完成，缓冲响应
            pendingNetworkResponse = response
        }
    }

    /// 网络错误回调
    func onNetworkError(_ error: Error) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        if diskCheckCompleted {
            if cacheEmitted {
                // 有缓存已发射，忽略错误
                observer.onCompleted()
            } else {
                // 无缓存，传递错误
                observer.onError(error)
            }
        } else {
            pendingNetworkError = error
        }
    }

    /// 网络完成回调
    func onNetworkCompleted() {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        networkCompleted = true

        if diskCheckCompleted {
            observer.onCompleted()
        }
    }

    func dispose() {
        lock.lock()
        disposed = true
        lock.unlock()
    }
}

/// 泛型 firstCache 协调器（用于 adapt 方法）
///
/// 与 FirstCacheCoordinator 功能相同，但支持 Any 类型
private final class GenericFirstCacheCoordinator: @unchecked Sendable {
    private let lock = NSLock()
    private let observer: AnyObserver<Any>

    // 状态
    private var diskCheckCompleted = false
    private var cacheEmitted = false
    private var disposed = false

    // 缓冲的网络响应
    private var pendingNetworkResponse: Any?
    private var pendingNetworkError: Error?
    private var networkCompleted = false

    init(observer: AnyObserver<Any>) {
        self.observer = observer
    }

    /// 磁盘缓存检查完成回调
    func onDiskCacheResult(_ cached: Response?) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        diskCheckCompleted = true

        // 如果有磁盘缓存，先发射
        if let cached = cached {
            cacheEmitted = true
            observer.onNext(cached)
        }

        // 处理缓冲的网络响应
        flushPendingNetworkEvents()
    }

    /// 网络响应回调
    func onNetworkResponse(_ response: Any) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        if diskCheckCompleted {
            observer.onNext(response)
        } else {
            pendingNetworkResponse = response
        }
    }

    /// 网络错误回调
    func onNetworkError(_ error: Error) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        if diskCheckCompleted {
            if cacheEmitted {
                observer.onCompleted()
            } else {
                observer.onError(error)
            }
        } else {
            pendingNetworkError = error
        }
    }

    /// 网络完成回调
    func onNetworkCompleted() {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        networkCompleted = true

        if diskCheckCompleted {
            observer.onCompleted()
        }
    }

    /// 释放资源
    func dispose() {
        lock.lock()
        disposed = true
        lock.unlock()
    }

    /// 刷新缓冲的网络事件（在锁内调用）
    private func flushPendingNetworkEvents() {
        if let response = pendingNetworkResponse {
            pendingNetworkResponse = nil
            observer.onNext(response)
        }

        if let error = pendingNetworkError {
            pendingNetworkError = nil
            if cacheEmitted {
                observer.onCompleted()
            } else {
                observer.onError(error)
            }
            return
        }

        if networkCompleted {
            observer.onCompleted()
        }
    }
}

/// 泛型 ifCache 协调器（用于 adapt 方法）
private final class GenericIfCacheCoordinator: @unchecked Sendable {
    private let lock = NSLock()
    private let observer: AnyObserver<Any>

    private var diskCheckCompleted = false
    private var emitted = false
    private var disposed = false

    private var pendingNetworkResponse: Any?
    private var pendingNetworkError: Error?

    init(observer: AnyObserver<Any>) {
        self.observer = observer
    }

    func onDiskCacheResult(_ cached: Response?) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed, !emitted else { return }

        diskCheckCompleted = true

        if let cached = cached {
            emitted = true
            observer.onNext(cached)
            observer.onCompleted()
            return
        }

        if let response = pendingNetworkResponse {
            emitted = true
            observer.onNext(response)
            observer.onCompleted()
        } else if let error = pendingNetworkError {
            emitted = true
            observer.onError(error)
        }
    }

    func onNetworkResponse(_ response: Any) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed, !emitted else { return }

        if diskCheckCompleted {
            emitted = true
            observer.onNext(response)
            observer.onCompleted()
        } else {
            pendingNetworkResponse = response
        }
    }

    func onNetworkError(_ error: Error) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed, !emitted else { return }

        if diskCheckCompleted {
            emitted = true
            observer.onError(error)
        } else {
            pendingNetworkError = error
        }
    }

    func onNetworkCompleted() {}

    func dispose() {
        lock.lock()
        disposed = true
        lock.unlock()
    }
}

/// 泛型 lastCache 协调器（用于 adapt 方法）
private final class GenericLastCacheCoordinator: @unchecked Sendable {
    private let lock = NSLock()
    private let observer: AnyObserver<Any>

    private var diskCheckCompleted = false
    private var cacheEmitted = false
    private var disposed = false

    private var pendingNetworkResponse: Any?
    private var pendingNetworkError: Error?
    private var networkCompleted = false

    init(observer: AnyObserver<Any>) {
        self.observer = observer
    }

    func onDiskCacheResult(_ cached: Response?) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        diskCheckCompleted = true

        if let cached = cached {
            cacheEmitted = true
            observer.onNext(cached)
            if networkCompleted {
                observer.onCompleted()
            }
            return
        }

        if let response = pendingNetworkResponse {
            observer.onNext(response)
            if networkCompleted {
                observer.onCompleted()
            }
        } else if let error = pendingNetworkError {
            observer.onError(error)
        } else if networkCompleted {
            observer.onCompleted()
        }
    }

    func onNetworkResponse(_ response: Any) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        if diskCheckCompleted {
            if !cacheEmitted {
                observer.onNext(response)
            }
        } else {
            pendingNetworkResponse = response
        }
    }

    func onNetworkError(_ error: Error) {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        if diskCheckCompleted {
            if cacheEmitted {
                observer.onCompleted()
            } else {
                observer.onError(error)
            }
        } else {
            pendingNetworkError = error
        }
    }

    func onNetworkCompleted() {
        lock.lock()
        defer { lock.unlock() }
        guard !disposed else { return }

        networkCompleted = true

        if diskCheckCompleted {
            observer.onCompleted()
        }
    }

    func dispose() {
        lock.lock()
        disposed = true
        lock.unlock()
    }
}

// MARK: - CachingRxCallAdapter

/// 缓存 RxSwift 请求适配器
///
/// 根据 `RestApiService` 配置的缓存策略自动处理缓存逻辑。
/// 内部使用，由 `HttpMoyaProvider` 自动管理。
///
/// ## 特性
/// - 自动识别缓存策略
/// - 支持多种缓存模式
/// - 支持业务自定义缓存实例
/// - 错误时优雅降级
/// - 线程安全
final class CachingRxCallAdapter: RxCallAdapter, @unchecked Sendable {
    // MARK: - Singleton

    /// 共享实例
    static let shared = CachingRxCallAdapter()

    // MARK: - Properties

    /// 默认缓存管理器（当 target 未指定时使用）
    private let defaultCache: HttpCache

    // MARK: - Initialization

    /// 初始化适配器
    /// - Parameter cache: 默认缓存管理器，当 target 未指定自定义缓存时使用
    init(cache: HttpCache = .shared) {
        self.defaultCache = cache
    }

    // MARK: - Private Helpers

    /// 获取目标使用的缓存实例
    /// - Parameter target: 请求目标
    /// - Returns: 缓存实例（优先使用 target 配置的，否则使用默认实例）
    private func getCache(for target: TargetType) -> HttpCache {
        // 尝试从 RestApiService 获取自定义缓存实例
        if let restApi = target as? any RestApiService {
            return type(of: restApi).httpCache
        }
        return defaultCache
    }

    // MARK: - RxCallAdapter Protocol

    /// 适配泛型 Observable
    /// - Parameters:
    ///   - observable: 原始 Observable
    ///   - target: 请求目标
    /// - Returns: 处理后的 Observable
    func adapt<O: ObservableConvertibleType>(_ observable: O, target: TargetType) -> O {
        // 如果不是 RestApiService，直接返回原始流
        guard let restApi = target as? any RestApiService else {
            return observable
        }

        let cachePolicy = restApi.cachePolicy

        // 不需要缓存直接返回
        guard cachePolicy.needsCache else {
            return observable
        }

        // 获取缓存参数
        let maxAge = cachePolicy.maxAge
        let key = restApi.cacheKey
        let interceptor = type(of: restApi).cacheInterceptor
        let cache = getCache(for: target)

        // 参数校验
        guard !key.isEmpty else {
            #if DEBUG
                print("[CachingRxCallAdapter] Warning: Empty cache key, skipping cache")
            #endif
            return observable
        }

        // 将原始流转换为 Observable
        let sourceObservable = observable.asObservable()

        // 根据缓存策略处理
        let resultObservable: Observable<Any> = switch cachePolicy {
        case .onlyRemote:
            sourceObservable.map { $0 as Any }
        case .firstCache:
            handleFirstCache(source: sourceObservable, key: key, maxAge: maxAge, interceptor: interceptor, cache: cache)
        case .firstRemote:
            handleFirstRemote(source: sourceObservable, key: key, maxAge: maxAge, interceptor: interceptor, cache: cache)
        case .onlyCache:
            handleOnlyCache(key: key, maxAge: maxAge, cache: cache)
        case .ifCache:
            handleIfCache(source: sourceObservable, key: key, maxAge: maxAge, interceptor: interceptor, cache: cache)
        case .lastCache:
            handleLastCache(source: sourceObservable, key: key, maxAge: maxAge, interceptor: interceptor, cache: cache)
        }

        // 尝试转换回原始类型
        if let result = resultObservable as? O {
            return result
        }

        let mapped = resultObservable.compactMap { $0 as? O.Element }
        if let result = mapped as? O {
            return result
        }

        return observable
    }

    /// 专门用于返回 Observable<Response> 的适配方法
    ///
    /// 支持缓存模式的多次发射（如 firstCache 可发射 1-2 次）
    /// - Parameters:
    ///   - single: 原始网络请求
    ///   - target: 请求目标
    /// - Returns: 处理后的 Observable
    func adaptToObservable(_ single: Single<Response>, target: TargetType) -> Observable<Response> {
        // 如果不是 RestApiService，直接返回
        guard let restApi = target as? any RestApiService else {
            return single.asObservable()
        }

        let cachePolicy = restApi.cachePolicy

        // 不需要缓存直接返回
        guard cachePolicy.needsCache else {
            return single.asObservable()
        }

        // 获取缓存参数
        let maxAge = cachePolicy.maxAge
        let key = restApi.cacheKey
        let interceptor = type(of: restApi).cacheInterceptor
        let cache = getCache(for: target)
        let source = single.asObservable()

        // 参数校验
        guard !key.isEmpty else {
            #if DEBUG
                print("[CachingRxCallAdapter] Warning: Empty cache key, skipping cache")
            #endif
            return source
        }

        // 根据缓存策略处理，返回 Observable<Response>
        switch cachePolicy {
        case .onlyRemote:
            return source
        case .firstCache:
            return firstCache(source: source, key: key, maxAge: maxAge, interceptor: interceptor, cache: cache)
        case .firstRemote:
            return firstRemote(source: source, key: key, maxAge: maxAge, interceptor: interceptor, cache: cache)
        case .onlyCache:
            return onlyCache(key: key, maxAge: maxAge, cache: cache)
        case .ifCache:
            return ifCache(source: source, key: key, maxAge: maxAge, interceptor: interceptor, cache: cache)
        case .lastCache:
            return lastCache(source: source, key: key, maxAge: maxAge, interceptor: interceptor, cache: cache)
        }
    }
}

// MARK: - Observable<Response> 缓存策略实现

private extension CachingRxCallAdapter {
    /// firstCache: 先返回缓存，再请求网络
    ///
    /// 可能发射 1-2 次：
    /// - 有缓存：发射缓存 → 发射网络响应（或完成）
    /// - 无缓存：发射网络响应（或错误）
    ///
    /// 关键：使用 concat 串行执行，磁盘检查完成后才开始网络请求
    /// 这确保了缓存和网络响应之间有明显的时间差
    func firstCache(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Response> {
        // 1. 同步检查内存缓存（非常快，不阻塞）
        let memoryCached = cache.getFromMemory(forKey: key, maxAge: maxAge)

        // 网络请求（带缓存写入）
        let networkObservable = source
            .do(onNext: { response in
                #if DEBUG
                    print("[CachingRxCallAdapter] firstCache: Network response received for key '\(key)'")
                #endif
                cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
            })

        // 内存命中：直接 concat，缓存先发射，网络后发射
        if let cached = memoryCached {
            #if DEBUG
                print("[CachingRxCallAdapter] firstCache: Memory cache hit for key '\(key)'")
            #endif
            return Observable.concat([
                Observable.just(cached),
                networkObservable
            ])
        }

        // 内存未命中：创建磁盘缓存 Observable
        // 使用 deferred + 同步读取，确保缓存先返回
        let diskCacheObservable = Observable<Response>.deferred {
            #if DEBUG
                let startTime = Date()
            #endif

            // 同步检查磁盘缓存（在 subscribeOn 指定的线程上执行）
            if let cached = cache.get(forKey: key, maxAge: maxAge) {
                #if DEBUG
                    let duration = Date().timeIntervalSince(startTime)
                    print("[CachingRxCallAdapter] firstCache: Disk cache hit for key '\(key)', read took \(String(format: "%.3f", duration))s")
                #endif
                return Observable.just(cached)
            }

            #if DEBUG
                let duration = Date().timeIntervalSince(startTime)
                print("[CachingRxCallAdapter] firstCache: Disk cache miss for key '\(key)', check took \(String(format: "%.3f", duration))s")
            #endif
            return Observable.empty()
        }

        // concat: 磁盘检查完成 → 发射缓存（如果有）→ 网络请求开始 → 发射网络响应
        // 这确保了缓存和网络响应之间有明显的时间差
        return Observable.concat([
            diskCacheObservable,
            networkObservable
        ])
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }

    /// firstRemote: 先请求网络，失败时回退缓存
    ///
    /// 优化：网络失败时，先检查内存缓存，再异步读取磁盘缓存
    /// 线程：缓存数据在回调线程发射，由订阅者决定接收线程
    func firstRemote(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Response> {
        source
            .do(onNext: { response in
                cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
            })
            .catch { error -> Observable<Response> in
                // 网络失败，先检查内存缓存（同步，快）
                if let cached = cache.getFromMemory(forKey: key, maxAge: maxAge) {
                    return .just(cached)
                }
                // 内存无缓存，异步读取磁盘
                return Observable<Response>.create { rawObserver in
                    let observer = SendableObserver(rawObserver)
                    cache.get(forKey: key, maxAge: maxAge) { [observer] diskCached in
                        if let cached = diskCached {
                            observer.onNext(cached)
                            observer.onCompleted()
                        } else {
                            observer.onError(error)
                        }
                    }
                    return Disposables.create()
                }
            }
    }

    /// onlyCache: 只读缓存，没有则 empty
    ///
    /// 优化：先检查内存缓存，再异步读取磁盘缓存
    /// 线程：缓存数据在回调线程发射，由订阅者决定接收线程
    func onlyCache(key: String, maxAge: TimeInterval, cache: HttpCache) -> Observable<Response> {
        // 先检查内存缓存（同步，快）
        if let cached = cache.getFromMemory(forKey: key, maxAge: maxAge) {
            return .just(cached)
        }
        // 内存无缓存，异步读取磁盘
        return Observable<Response>.create { rawObserver in
            let observer = SendableObserver(rawObserver)
            cache.get(forKey: key, maxAge: maxAge) { [observer] diskCached in
                if let cached = diskCached {
                    observer.onNext(cached)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    /// ifCache: 有缓存用缓存，无缓存走网络
    ///
    /// 关键：使用串行执行，磁盘检查完成后才决定是否发起网络请求
    /// - 有缓存：直接发射缓存，完成（不发起网络请求）
    /// - 无缓存：发起网络请求
    ///
    /// 线程：缓存数据在回调线程发射，网络数据在网络线程发射，由订阅者决定接收线程
    func ifCache(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Response> {
        // 1. 先检查内存缓存（同步，快）
        if let cached = cache.getFromMemory(forKey: key, maxAge: maxAge) {
            #if DEBUG
                print("[CachingRxCallAdapter] ifCache: Memory cache hit for key '\(key)'")
            #endif
            return .just(cached)
        }

        // 2. 网络请求（带缓存写入）
        let networkObservable = source
            .do(onNext: { response in
                cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
            })

        // 3. 内存未命中：创建磁盘缓存检查 Observable
        // 使用 deferred + 同步读取，确保磁盘检查完成后再决定
        let diskCacheObservable = Observable<Response>.deferred {
            #if DEBUG
                let startTime = Date()
            #endif

            // 同步检查磁盘缓存（在 subscribeOn 指定的线程上执行）
            if let cached = cache.get(forKey: key, maxAge: maxAge) {
                #if DEBUG
                    let duration = Date().timeIntervalSince(startTime)
                    print("[CachingRxCallAdapter] ifCache: Disk cache hit for key '\(key)', read took \(String(format: "%.3f", duration))s")
                #endif
                // 有缓存，发射缓存并完成（不发起网络请求）
                return Observable.just(cached)
            }

            #if DEBUG
                let duration = Date().timeIntervalSince(startTime)
                print("[CachingRxCallAdapter] ifCache: Disk cache miss for key '\(key)', check took \(String(format: "%.3f", duration))s")
            #endif
            // 无缓存，返回 empty 让 concat 继续执行网络请求
            return Observable.empty()
        }

        // 4. 串行执行：磁盘检查 → 有缓存则完成，无缓存则网络请求
        // 如果磁盘有缓存，just(cached) 发射后序列完成，不会执行 networkObservable
        // 如果磁盘无缓存，empty() 完成后继续执行 networkObservable
        return Observable.concat([
            diskCacheObservable,
            networkObservable
        ])
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }

    /// lastCache: 返回缓存后静默更新网络
    ///
    /// - 有缓存：返回缓存，静默请求网络更新缓存（只发射一次）
    /// - 无缓存：返回网络响应
    ///
    /// 关键：使用串行执行，磁盘检查完成后才决定后续行为
    /// 线程：缓存数据在回调线程发射，网络数据在网络线程发射，由订阅者决定接收线程
    func lastCache(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Response> {
        // 1. 先检查内存缓存（同步，快）
        let memoryCached = cache.getFromMemory(forKey: key, maxAge: maxAge)

        // 2. 网络请求（带缓存写入）
        let networkObservable = source.do(onNext: { response in
            cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
        })

        // 3. 内存命中：发射缓存，静默更新网络
        if let cached = memoryCached {
            #if DEBUG
                print("[CachingRxCallAdapter] lastCache: Memory cache hit for key '\(key)'")
            #endif
            return Observable<Response>.create { rawObserver in
                let observer = SendableObserver(rawObserver)
                let disposeBag = CompositeDisposable()

                // 发射缓存
                observer.onNext(cached)

                // 静默更新网络（不发射响应）
                let disposable = networkObservable.subscribe(
                    onNext: { _ in },
                    onError: { _ in observer.onCompleted() },
                    onCompleted: { observer.onCompleted() }
                )
                _ = disposeBag.insert(disposable)

                return disposeBag
            }
        }

        // 4. 内存未命中：使用串行执行
        // 先检查磁盘缓存，根据结果决定后续行为
        return Observable<Response>.deferred { [networkObservable] in
            #if DEBUG
                let startTime = Date()
            #endif

            // 同步检查磁盘缓存（在 subscribeOn 指定的线程上执行）
            if let cached = cache.get(forKey: key, maxAge: maxAge) {
                #if DEBUG
                    let duration = Date().timeIntervalSince(startTime)
                    print("[CachingRxCallAdapter] lastCache: Disk cache hit for key '\(key)', read took \(String(format: "%.3f", duration))s")
                #endif
                // 有缓存：发射缓存，静默更新网络
                return Observable<Response>.create { rawObserver in
                    let observer = SendableObserver(rawObserver)
                    let disposeBag = CompositeDisposable()

                    // 发射缓存
                    observer.onNext(cached)

                    // 静默更新网络（不发射响应）
                    let disposable = networkObservable.subscribe(
                        onNext: { _ in },
                        onError: { _ in observer.onCompleted() },
                        onCompleted: { observer.onCompleted() }
                    )
                    _ = disposeBag.insert(disposable)

                    return disposeBag
                }
            }

            #if DEBUG
                let duration = Date().timeIntervalSince(startTime)
                print("[CachingRxCallAdapter] lastCache: Disk cache miss for key '\(key)', check took \(String(format: "%.3f", duration))s")
            #endif
            // 无缓存：返回网络请求
            return networkObservable
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }
}

// MARK: - 泛型缓存策略实现（用于 adapt 方法）

private extension CachingRxCallAdapter {
    /// firstCache: 先返回缓存，再请求网络（可能发射 1-2 次）
    ///
    /// 关键：使用 concat 串行执行，磁盘检查完成后才开始网络请求
    func handleFirstCache(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Any> {
        // 同步检查内存缓存
        let memoryCached = cache.getFromMemory(forKey: key, maxAge: maxAge)

        // 网络请求（带缓存写入）
        let networkObservable = source.map { element -> Any in
            if let response = element as? Response {
                cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
            }
            return element
        }

        // 内存命中：直接 concat
        if let cached = memoryCached {
            return Observable.concat([
                Observable.just(cached as Any),
                networkObservable
            ])
        }

        // 内存未命中：创建磁盘缓存 Observable
        let diskCacheObservable = Observable<Any>.deferred {
            if let cached = cache.get(forKey: key, maxAge: maxAge) {
                return Observable.just(cached as Any)
            }
            return Observable.empty()
        }

        // concat: 磁盘检查完成 → 发射缓存（如果有）→ 网络请求开始 → 发射网络响应
        return Observable.concat([
            diskCacheObservable,
            networkObservable
        ])
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }

    /// firstRemote: 先请求网络，失败时回退缓存
    ///
    /// 优化：网络失败时，先检查内存缓存，再异步读取磁盘
    func handleFirstRemote(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Any> {
        source
            .map { element -> Any in
                if let response = element as? Response {
                    cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
                }
                return element
            }
            .catch { error -> Observable<Any> in
                // 先检查内存缓存
                if let cachedResponse = cache.getFromMemory(forKey: key, maxAge: maxAge) {
                    return .just(cachedResponse)
                }
                // 异步读取磁盘
                return Observable<Any>.create { rawObserver in
                    let observer = SendableObserver(rawObserver)
                    cache.get(forKey: key, maxAge: maxAge) { [observer] diskCached in
                        if let cached = diskCached {
                            observer.onNext(cached)
                            observer.onCompleted()
                        } else {
                            observer.onError(error)
                        }
                    }
                    return Disposables.create()
                }
            }
    }

    /// onlyCache: 只读缓存，没有则 empty
    ///
    /// 优化：先检查内存缓存，再异步读取磁盘
    func handleOnlyCache(key: String, maxAge: TimeInterval, cache: HttpCache) -> Observable<Any> {
        // 先检查内存缓存
        if let cachedResponse = cache.getFromMemory(forKey: key, maxAge: maxAge) {
            return .just(cachedResponse)
        }
        // 异步读取磁盘
        return Observable<Any>.create { rawObserver in
            let observer = SendableObserver(rawObserver)
            cache.get(forKey: key, maxAge: maxAge) { [observer] diskCached in
                if let cached = diskCached {
                    observer.onNext(cached)
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    /// ifCache: 有缓存用缓存，无缓存走网络
    ///
    /// 关键：使用串行执行，磁盘检查完成后才决定是否发起网络请求
    func handleIfCache(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Any> {
        // 1. 先检查内存缓存
        if let cachedResponse = cache.getFromMemory(forKey: key, maxAge: maxAge) {
            return .just(cachedResponse)
        }

        // 2. 网络请求（带缓存写入）
        let networkObservable = source.map { element -> Any in
            if let response = element as? Response {
                cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
            }
            return element
        }

        // 3. 内存未命中：创建磁盘缓存检查 Observable
        let diskCacheObservable = Observable<Any>.deferred {
            // 同步检查磁盘缓存（在 subscribeOn 指定的线程上执行）
            if let cached = cache.get(forKey: key, maxAge: maxAge) {
                // 有缓存，发射缓存并完成（不发起网络请求）
                return Observable.just(cached as Any)
            }
            // 无缓存，返回 empty 让 concat 继续执行网络请求
            return Observable.empty()
        }

        // 4. 串行执行：磁盘检查 → 有缓存则完成，无缓存则网络请求
        return Observable.concat([
            diskCacheObservable,
            networkObservable
        ])
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }

    /// lastCache: 返回缓存后静默更新网络（有缓存时只发射一次）
    ///
    /// 关键：使用串行执行，磁盘检查完成后才决定后续行为
    func handleLastCache(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Any> {
        // 1. 先检查内存缓存
        let memoryCached = cache.getFromMemory(forKey: key, maxAge: maxAge)

        // 2. 网络请求（带缓存写入）
        let networkObservable = source.map { element -> Any in
            if let response = element as? Response {
                cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
            }
            return element
        }

        // 3. 内存命中：发射缓存，静默更新网络
        if let cached = memoryCached {
            return Observable<Any>.create { rawObserver in
                let observer = SendableObserver(rawObserver)
                let disposeBag = CompositeDisposable()

                // 发射缓存
                observer.onNext(cached)

                // 静默更新网络（不发射响应）
                let disposable = networkObservable.subscribe(
                    onNext: { _ in },
                    onError: { _ in observer.onCompleted() },
                    onCompleted: { observer.onCompleted() }
                )
                _ = disposeBag.insert(disposable)

                return disposeBag
            }
        }

        // 4. 内存未命中：使用串行执行
        return Observable<Any>.deferred { [networkObservable] in
            // 同步检查磁盘缓存（在 subscribeOn 指定的线程上执行）
            if let cached = cache.get(forKey: key, maxAge: maxAge) {
                // 有缓存：发射缓存，静默更新网络
                return Observable<Any>.create { rawObserver in
                    let observer = SendableObserver(rawObserver)
                    let disposeBag = CompositeDisposable()

                    // 发射缓存
                    observer.onNext(cached)

                    // 静默更新网络（不发射响应）
                    let disposable = networkObservable.subscribe(
                        onNext: { _ in },
                        onError: { _ in observer.onCompleted() },
                        onCompleted: { observer.onCompleted() }
                    )
                    _ = disposeBag.insert(disposable)

                    return disposeBag
                }
            }
            // 无缓存：返回网络请求
            return networkObservable
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }
}
