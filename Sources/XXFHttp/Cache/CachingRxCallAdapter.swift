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
//  Created by xxf on 2026/3/4.
//

import Foundation
@preconcurrency import Moya
@preconcurrency import RxSwift

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
    /// - 有缓存：发射缓存 → 发射网络响应
    /// - 无缓存：发射网络响应（或错误）
    func firstCache(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Response> {
        // 网络请求（带缓存写入）
        let networkObservable = source
            .do(onNext: { response in
                cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
            })

        // concat: 缓存（如果有）→ 网络响应
        // getAsObservable 内部处理内存优先、磁盘回退
        return Observable.concat([
            cache.getAsObservable(forKey: key, maxAge: maxAge),
            networkObservable
        ])
    }

    /// firstRemote: 先请求网络，失败时回退缓存
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
                // 网络失败，尝试从缓存获取
                cache.getAsObservable(forKey: key, maxAge: maxAge)
                    .ifEmpty(switchTo: .error(error))
            }
    }

    /// onlyCache: 只读缓存，没有则 empty
    func onlyCache(key: String, maxAge: TimeInterval, cache: HttpCache) -> Observable<Response> {
        cache.getAsObservable(forKey: key, maxAge: maxAge)
    }

    /// ifCache: 有缓存用缓存，无缓存走网络
    func ifCache(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Response> {
        // 网络请求（带缓存写入）
        let networkObservable = source
            .do(onNext: { response in
                cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
            })

        // 有缓存用缓存，无缓存走网络
        return cache.getAsObservable(forKey: key, maxAge: maxAge)
            .ifEmpty(switchTo: networkObservable)
    }

    /// lastCache: 返回缓存后静默更新网络
    ///
    /// - 有缓存：返回缓存，静默请求网络更新缓存（只发射一次）
    /// - 无缓存：返回网络响应
    func lastCache(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Response> {
        // 网络请求（带缓存写入）
        let networkObservable = source.do(onNext: { response in
            cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
        })

        // 获取缓存
        let cacheObservable = cache.getAsObservable(forKey: key, maxAge: maxAge)

        // 使用 flatMap 实现：有缓存则发射缓存并静默更新，无缓存则发射网络
        return cacheObservable
            .flatMap { cached -> Observable<Response> in
                // 有缓存：发射缓存，静默更新网络
                Observable<Response>.create { observer in
                    let disposeBag = CompositeDisposable()

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
            .ifEmpty(switchTo: networkObservable)
    }
}

// MARK: - 泛型缓存策略实现（用于 adapt 方法）

private extension CachingRxCallAdapter {
    /// firstCache: 先返回缓存，再请求网络（可能发射 1-2 次）
    func handleFirstCache(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Any> {
        // 网络请求（带缓存写入）
        let networkObservable = source.map { element -> Any in
            if let response = element as? Response {
                cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
            }
            return element
        }

        // concat: 缓存（如果有）→ 网络响应
        return Observable.concat([
            cache.getAsObservable(forKey: key, maxAge: maxAge).map { $0 as Any },
            networkObservable
        ])
    }

    /// firstRemote: 先请求网络，失败时回退缓存
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
                cache.getAsObservable(forKey: key, maxAge: maxAge)
                    .map { $0 as Any }
                    .ifEmpty(switchTo: .error(error))
            }
    }

    /// onlyCache: 只读缓存，没有则 empty
    func handleOnlyCache(key: String, maxAge: TimeInterval, cache: HttpCache) -> Observable<Any> {
        cache.getAsObservable(forKey: key, maxAge: maxAge).map { $0 as Any }
    }

    /// ifCache: 有缓存用缓存，无缓存走网络
    func handleIfCache(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Any> {
        // 网络请求（带缓存写入）
        let networkObservable = source.map { element -> Any in
            if let response = element as? Response {
                cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
            }
            return element
        }

        // 有缓存用缓存，无缓存走网络
        return cache.getAsObservable(forKey: key, maxAge: maxAge)
            .map { $0 as Any }
            .ifEmpty(switchTo: networkObservable)
    }

    /// lastCache: 返回缓存后静默更新网络（有缓存时只发射一次）
    func handleLastCache(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor,
        cache: HttpCache
    ) -> Observable<Any> {
        // 网络请求（带缓存写入）
        let networkObservable = source.map { element -> Any in
            if let response = element as? Response {
                cache.set(response, forKey: key, maxAge: maxAge, interceptor: interceptor)
            }
            return element
        }

        // 获取缓存
        let cacheObservable = cache.getAsObservable(forKey: key, maxAge: maxAge)

        // 使用 flatMap 实现：有缓存则发射缓存并静默更新，无缓存则发射网络
        return cacheObservable
            .flatMap { cached -> Observable<Any> in
                Observable<Any>.create { observer in
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
            .ifEmpty(switchTo: networkObservable)
    }
}
