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
//
//  Created by xxf on 2025/3/4.
//

import Foundation
import Moya
import RxSwift

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
    /// 优化：内存缓存同步检查（毫秒级），磁盘缓存异步读取
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
                cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
            })

        return Observable<Response>.create { observer in
            // 使用锁保护状态变量，防止竞态条件
            let lock = NSLock()
            var hasCacheEmitted = false
            var hasNetworkEmitted = false
            let disposeBag = CompositeDisposable()

            // 2. 如果内存有缓存，立即发射
            if let cached = memoryCached {
                hasCacheEmitted = true
                observer.onNext(cached)
            } else {
                // 3. 内存未命中，异步读取磁盘
                cache.get(forKey: key, maxAge: maxAge) { diskCached in
                    lock.lock()
                    let shouldEmit = !hasNetworkEmitted // 只有网络还没返回时才发射缓存
                    if diskCached != nil {
                        hasCacheEmitted = true
                    }
                    lock.unlock()

                    if shouldEmit, let cached = diskCached {
                        DispatchQueue.main.async {
                            observer.onNext(cached)
                        }
                    }
                }
            }

            // 4. 同时发起网络请求
            let networkDisposable = networkObservable
                .observe(on: MainScheduler.instance)
                .subscribe(
                    onNext: { response in
                        lock.lock()
                        hasNetworkEmitted = true
                        let cacheEmitted = hasCacheEmitted
                        lock.unlock()

                        observer.onNext(response)
                    },
                    onError: { error in
                        lock.lock()
                        let cacheEmitted = hasCacheEmitted
                        lock.unlock()

                        if cacheEmitted {
                            observer.onCompleted()
                        } else {
                            observer.onError(error)
                        }
                    },
                    onCompleted: {
                        observer.onCompleted()
                    }
                )
            _ = disposeBag.insert(networkDisposable)

            return disposeBag
        }
    }

    /// firstRemote: 先请求网络，失败时回退缓存
    ///
    /// 优化：网络失败时，先检查内存缓存，再异步读取磁盘缓存
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
                return Observable<Response>.create { observer in
                    cache.get(forKey: key, maxAge: maxAge) { diskCached in
                        DispatchQueue.main.async {
                            if let cached = diskCached {
                                observer.onNext(cached)
                                observer.onCompleted()
                            } else {
                                observer.onError(error)
                            }
                        }
                    }
                    return Disposables.create()
                }
            }
    }

    /// onlyCache: 只读缓存，没有则 empty
    ///
    /// 优化：先检查内存缓存，再异步读取磁盘缓存
    func onlyCache(key: String, maxAge: TimeInterval, cache: HttpCache) -> Observable<Response> {
        // 先检查内存缓存（同步，快）
        if let cached = cache.getFromMemory(forKey: key, maxAge: maxAge) {
            return .just(cached)
        }
        // 内存无缓存，异步读取磁盘
        return Observable<Response>.create { observer in
            cache.get(forKey: key, maxAge: maxAge) { diskCached in
                DispatchQueue.main.async {
                    if let cached = diskCached {
                        observer.onNext(cached)
                    }
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    /// ifCache: 有缓存用缓存，无缓存走网络
    ///
    /// 优化：先检查内存缓存，无内存缓存时并发读磁盘和网络
    func ifCache(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Response> {
        // 先检查内存缓存（同步，快）
        if let cached = cache.getFromMemory(forKey: key, maxAge: maxAge) {
            return .just(cached)
        }

        // 内存无缓存，异步检查磁盘，如果磁盘也没有则走网络
        return Observable<Response>.create { observer in
            let lock = NSLock()
            var hasEmitted = false
            let disposeBag = CompositeDisposable()

            // 异步读取磁盘
            cache.get(forKey: key, maxAge: maxAge) { diskCached in
                lock.lock()
                if !hasEmitted, let cached = diskCached {
                    hasEmitted = true
                    lock.unlock()
                    DispatchQueue.main.async {
                        observer.onNext(cached)
                        observer.onCompleted()
                    }
                } else {
                    lock.unlock()
                }
            }

            // 同时发起网络请求（延迟一小段时间给磁盘缓存机会）
            let networkDisposable = source
                .delay(.milliseconds(50), scheduler: MainScheduler.instance)
                .do(onNext: { response in
                    cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
                })
                .subscribe(
                    onNext: { response in
                        lock.lock()
                        if !hasEmitted {
                            hasEmitted = true
                            lock.unlock()
                            observer.onNext(response)
                            observer.onCompleted()
                        } else {
                            lock.unlock()
                        }
                    },
                    onError: { error in
                        lock.lock()
                        if !hasEmitted {
                            hasEmitted = true
                            lock.unlock()
                            observer.onError(error)
                        } else {
                            lock.unlock()
                        }
                    }
                )
            _ = disposeBag.insert(networkDisposable)

            return disposeBag
        }
    }

    /// lastCache: 返回缓存后静默更新网络
    ///
    /// - 有缓存：返回缓存，静默请求网络更新缓存
    /// - 无缓存：返回网络响应
    ///
    /// 优化：先检查内存缓存，磁盘读取异步化
    func lastCache(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Response> {
        // 先检查内存缓存（同步，快）
        let memoryCached = cache.getFromMemory(forKey: key, maxAge: maxAge)

        return Observable<Response>.create { observer in
            let lock = NSLock()
            var hasCacheEmitted = false
            let disposeBag = CompositeDisposable()

            // 如果内存有缓存，立即发射
            if let cached = memoryCached {
                hasCacheEmitted = true
                observer.onNext(cached)

                // 静默更新网络
                let disposable = source.subscribe(
                    onNext: { response in
                        cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
                    },
                    onError: { _ in
                        observer.onCompleted()
                    },
                    onCompleted: {
                        observer.onCompleted()
                    }
                )
                _ = disposeBag.insert(disposable)
            } else {
                // 内存无缓存，异步读取磁盘
                cache.get(forKey: key, maxAge: maxAge) { diskCached in
                    lock.lock()
                    if !hasCacheEmitted, let cached = diskCached {
                        hasCacheEmitted = true
                        lock.unlock()
                        DispatchQueue.main.async {
                            observer.onNext(cached)
                        }
                    } else {
                        lock.unlock()
                    }
                }

                // 同时发起网络请求
                let networkDisposable = source.subscribe(
                    onNext: { response in
                        cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)

                        lock.lock()
                        if !hasCacheEmitted {
                            hasCacheEmitted = true
                            lock.unlock()
                            observer.onNext(response)
                        } else {
                            lock.unlock()
                        }
                    },
                    onError: { error in
                        lock.lock()
                        let cacheEmitted = hasCacheEmitted
                        lock.unlock()

                        if cacheEmitted {
                            observer.onCompleted()
                        } else {
                            observer.onError(error)
                        }
                    },
                    onCompleted: {
                        observer.onCompleted()
                    }
                )
                _ = disposeBag.insert(networkDisposable)
            }

            return disposeBag
        }
    }
}

// MARK: - 泛型缓存策略实现（用于 adapt 方法）

private extension CachingRxCallAdapter {
    /// firstCache: 先返回缓存，再请求网络（可能发射 1-2 次）
    ///
    /// 优化：内存缓存同步检查，磁盘缓存异步读取
    func handleFirstCache(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Any> {
        // 同步检查内存缓存
        let memoryCached = cache.getFromMemory(forKey: key, maxAge: maxAge)

        return Observable<Any>.create { observer in
            let lock = NSLock()
            var hasCacheEmitted = false
            var hasNetworkEmitted = false
            let disposeBag = CompositeDisposable()

            // 如果内存有缓存，立即发射
            if let cached = memoryCached {
                hasCacheEmitted = true
                observer.onNext(cached)
            } else {
                // 内存未命中，异步读取磁盘
                cache.get(forKey: key, maxAge: maxAge) { diskCached in
                    lock.lock()
                    let shouldEmit = !hasNetworkEmitted
                    if diskCached != nil {
                        hasCacheEmitted = true
                    }
                    lock.unlock()

                    if shouldEmit, let cached = diskCached {
                        DispatchQueue.main.async {
                            observer.onNext(cached)
                        }
                    }
                }
            }

            // 发起网络请求
            let disposable = source.subscribe(
                onNext: { element in
                    if let response = element as? Response {
                        cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
                    }

                    lock.lock()
                    hasNetworkEmitted = true
                    lock.unlock()

                    observer.onNext(element)
                },
                onError: { error in
                    lock.lock()
                    let cacheEmitted = hasCacheEmitted
                    lock.unlock()

                    if cacheEmitted {
                        observer.onCompleted()
                    } else {
                        observer.onError(error)
                    }
                },
                onCompleted: {
                    observer.onCompleted()
                }
            )
            _ = disposeBag.insert(disposable)

            return disposeBag
        }
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
                return Observable<Any>.create { observer in
                    cache.get(forKey: key, maxAge: maxAge) { diskCached in
                        DispatchQueue.main.async {
                            if let cached = diskCached {
                                observer.onNext(cached)
                                observer.onCompleted()
                            } else {
                                observer.onError(error)
                            }
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
        return Observable<Any>.create { observer in
            cache.get(forKey: key, maxAge: maxAge) { diskCached in
                DispatchQueue.main.async {
                    if let cached = diskCached {
                        observer.onNext(cached)
                    }
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    /// ifCache: 有缓存用缓存，无缓存走网络
    ///
    /// 优化：先检查内存缓存，无内存缓存时并发读磁盘和网络
    func handleIfCache(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Any> {
        // 先检查内存缓存
        if let cachedResponse = cache.getFromMemory(forKey: key, maxAge: maxAge) {
            return .just(cachedResponse)
        }

        // 内存无缓存，异步检查磁盘，如果磁盘也没有则走网络
        return Observable<Any>.create { observer in
            let lock = NSLock()
            var hasEmitted = false
            let disposeBag = CompositeDisposable()

            // 异步读取磁盘
            cache.get(forKey: key, maxAge: maxAge) { diskCached in
                lock.lock()
                if !hasEmitted, let cached = diskCached {
                    hasEmitted = true
                    lock.unlock()
                    DispatchQueue.main.async {
                        observer.onNext(cached)
                        observer.onCompleted()
                    }
                } else {
                    lock.unlock()
                }
            }

            // 同时发起网络请求（延迟一小段时间给磁盘缓存机会）
            let networkDisposable = source
                .delay(.milliseconds(50), scheduler: MainScheduler.instance)
                .subscribe(
                    onNext: { element in
                        if let response = element as? Response {
                            cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
                        }

                        lock.lock()
                        if !hasEmitted {
                            hasEmitted = true
                            lock.unlock()
                            observer.onNext(element)
                            observer.onCompleted()
                        } else {
                            lock.unlock()
                        }
                    },
                    onError: { error in
                        lock.lock()
                        if !hasEmitted {
                            hasEmitted = true
                            lock.unlock()
                            observer.onError(error)
                        } else {
                            lock.unlock()
                        }
                    }
                )
            _ = disposeBag.insert(networkDisposable)

            return disposeBag
        }
    }

    /// lastCache: 返回缓存后静默更新网络（有缓存时只发射一次）
    ///
    /// 优化：先检查内存缓存，磁盘读取异步化
    func handleLastCache(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Any> {
        // 先检查内存缓存
        let memoryCached = cache.getFromMemory(forKey: key, maxAge: maxAge)

        return Observable<Any>.create { observer in
            let lock = NSLock()
            var hasCacheEmitted = false
            let disposeBag = CompositeDisposable()

            if let cached = memoryCached {
                hasCacheEmitted = true
                observer.onNext(cached)

                let disposable = source.subscribe(
                    onNext: { element in
                        if let response = element as? Response {
                            cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
                        }
                    },
                    onError: { _ in
                        observer.onCompleted()
                    },
                    onCompleted: {
                        observer.onCompleted()
                    }
                )
                _ = disposeBag.insert(disposable)
            } else {
                // 内存无缓存，异步读取磁盘
                cache.get(forKey: key, maxAge: maxAge) { diskCached in
                    lock.lock()
                    if !hasCacheEmitted, let cached = diskCached {
                        hasCacheEmitted = true
                        lock.unlock()
                        DispatchQueue.main.async {
                            observer.onNext(cached)
                        }
                    } else {
                        lock.unlock()
                    }
                }

                // 同时发起网络请求
                let networkDisposable = source.subscribe(
                    onNext: { element in
                        if let response = element as? Response {
                            cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
                        }

                        lock.lock()
                        if !hasCacheEmitted {
                            hasCacheEmitted = true
                            lock.unlock()
                            observer.onNext(element)
                        } else {
                            lock.unlock()
                        }
                    },
                    onError: { error in
                        lock.lock()
                        let cacheEmitted = hasCacheEmitted
                        lock.unlock()

                        if cacheEmitted {
                            observer.onCompleted()
                        } else {
                            observer.onError(error)
                        }
                    },
                    onCompleted: {
                        observer.onCompleted()
                    }
                )
                _ = disposeBag.insert(networkDisposable)
            }

            return disposeBag
        }
    }
}
