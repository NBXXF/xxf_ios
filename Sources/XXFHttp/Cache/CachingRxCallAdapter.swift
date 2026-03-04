//
//  CachingRxCallAdapter.swift
//  xxf_ios
//
//  Created by xxf on 2025/3/4.
//

import Foundation
import Moya
import RxSwift

/// 缓存 RxSwift 请求适配器
/// 根据 RestApiService 配置的缓存策略自动处理缓存逻辑
/// 内部使用，由 HttpMoyaProvider 自动管理
final class CachingRxCallAdapter: RxCallAdapter, @unchecked Sendable {
    static let shared = CachingRxCallAdapter()

    private let cache: HttpCache

    init(cache: HttpCache = .shared) {
        self.cache = cache
    }

    func adapt<O: ObservableConvertibleType>(_ observable: O, target: TargetType) -> O {
        // 如果不是 RestApiService，直接返回原始流
        guard let restApi = target as? any RestApiService else {
            return observable
        }

        let cacheConfig = restApi.cacheConfig

        // 不需要缓存直接返回
        guard cacheConfig.needsCache else {
            return observable
        }

        let maxAge = cacheConfig.maxAge
        let key = restApi.cacheKey
        let interceptor = type(of: restApi).cacheInterceptor

        // 将原始流转换为 Observable
        let sourceObservable = observable.asObservable()

        // 根据缓存策略处理
        let resultObservable: Observable<Any> = switch cacheConfig {
        case .onlyRemote:
            sourceObservable.map { $0 as Any }
        case .firstCache:
            handleFirstCache(source: sourceObservable, key: key, maxAge: maxAge, interceptor: interceptor)
        case .firstRemote:
            handleFirstRemote(source: sourceObservable, key: key, maxAge: maxAge, interceptor: interceptor)
        case .onlyCache:
            handleOnlyCache(key: key, maxAge: maxAge)
        case .ifCache:
            handleIfCache(source: sourceObservable, key: key, maxAge: maxAge, interceptor: interceptor)
        case .lastCache:
            handleLastCache(source: sourceObservable, key: key, maxAge: maxAge, interceptor: interceptor)
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
    /// 支持缓存模式的多次发射（如 firstCache 可发射 1-2 次）
    func adaptToObservable(_ single: Single<Response>, target: TargetType) -> Observable<Response> {
        // 如果不是 RestApiService，直接返回
        guard let restApi = target as? any RestApiService else {
            return single.asObservable()
        }

        let cacheConfig = restApi.cacheConfig

        // 不需要缓存直接返回
        guard cacheConfig.needsCache else {
            return single.asObservable()
        }

        let maxAge = cacheConfig.maxAge
        let key = restApi.cacheKey
        let interceptor = type(of: restApi).cacheInterceptor
        let source = single.asObservable()

        // 根据缓存策略处理，返回 Observable<Response>
        switch cacheConfig {
        case .onlyRemote:
            return source
        case .firstCache:
            return firstCache(source: source, key: key, maxAge: maxAge, interceptor: interceptor)
        case .firstRemote:
            return firstRemote(source: source, key: key, maxAge: maxAge, interceptor: interceptor)
        case .onlyCache:
            return onlyCache(key: key, maxAge: maxAge)
        case .ifCache:
            return ifCache(source: source, key: key, maxAge: maxAge, interceptor: interceptor)
        case .lastCache:
            return lastCache(source: source, key: key, maxAge: maxAge, interceptor: interceptor)
        }
    }
}

// MARK: - Observable<Response> 缓存策略实现

private extension CachingRxCallAdapter {
    /// firstCache: 先返回缓存，再请求网络（可能发射 1-2 次）
    func firstCache(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor
    ) -> Observable<Response> {
        Observable<Response>.create { [cache] observer in
            var hasCacheEmitted = false

            // 1. 先检查缓存
            if let cached = cache.get(forKey: key, maxAge: maxAge) {
                observer.onNext(cached)
                hasCacheEmitted = true
            }

            // 2. 发起网络请求
            let disposable = source.subscribe(
                onNext: { response in
                    cache.set(response, forKey: key, interceptor: interceptor)
                    observer.onNext(response)
                },
                onError: { error in
                    if hasCacheEmitted {
                        observer.onCompleted()
                    } else {
                        observer.onError(error)
                    }
                },
                onCompleted: {
                    observer.onCompleted()
                }
            )

            return disposable
        }
    }

    /// firstRemote: 先请求网络，失败时回退缓存
    func firstRemote(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor
    ) -> Observable<Response> {
        source
            .do(onNext: { [cache] response in
                cache.set(response, forKey: key, interceptor: interceptor)
            })
            .catch { [cache] error -> Observable<Response> in
                if let cached = cache.get(forKey: key, maxAge: maxAge) {
                    return .just(cached)
                }
                return .error(error)
            }
    }

    /// onlyCache: 只读缓存，没有则 empty
    func onlyCache(key: String, maxAge: TimeInterval) -> Observable<Response> {
        if let cached = cache.get(forKey: key, maxAge: maxAge) {
            return .just(cached)
        }
        return .empty()
    }

    /// ifCache: 有缓存用缓存，无缓存走网络
    func ifCache(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor
    ) -> Observable<Response> {
        if let cached = cache.get(forKey: key, maxAge: maxAge) {
            return .just(cached)
        }

        return source.do(onNext: { [cache] response in
            cache.set(response, forKey: key, interceptor: interceptor)
        })
    }

    /// lastCache: 返回缓存后静默更新网络（有缓存时只发射一次）
    func lastCache(
        source: Observable<Response>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor
    ) -> Observable<Response> {
        Observable<Response>.create { [cache] observer in
            if let cached = cache.get(forKey: key, maxAge: maxAge) {
                // 有缓存：返回缓存，静默更新
                observer.onNext(cached)

                let disposable = source.subscribe(
                    onNext: { response in
                        cache.set(response, forKey: key, interceptor: interceptor)
                    },
                    onError: { _ in
                        observer.onCompleted()
                    },
                    onCompleted: {
                        observer.onCompleted()
                    }
                )
                return disposable
            } else {
                // 无缓存：返回网络
                let disposable = source.subscribe(
                    onNext: { response in
                        cache.set(response, forKey: key, interceptor: interceptor)
                        observer.onNext(response)
                    },
                    onError: { error in
                        observer.onError(error)
                    },
                    onCompleted: {
                        observer.onCompleted()
                    }
                )
                return disposable
            }
        }
    }
}

// MARK: - 泛型缓存策略实现（用于 adapt 方法）

private extension CachingRxCallAdapter {
    /// firstCache: 先返回缓存，再请求网络（可能发射 1-2 次）
    func handleFirstCache(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor
    ) -> Observable<Any> {
        Observable<Any>.create { [cache] observer in
            var hasCacheEmitted = false

            // 1. 先检查缓存
            if let cachedResponse = cache.get(forKey: key, maxAge: maxAge) {
                observer.onNext(cachedResponse)
                hasCacheEmitted = true
            }

            // 2. 发起网络请求
            let disposable = source.subscribe(
                onNext: { element in
                    if let response = element as? Response {
                        cache.set(response, forKey: key, interceptor: interceptor)
                    }
                    observer.onNext(element)
                },
                onError: { error in
                    if hasCacheEmitted {
                        observer.onCompleted()
                    } else {
                        observer.onError(error)
                    }
                },
                onCompleted: {
                    observer.onCompleted()
                }
            )

            return disposable
        }
    }

    /// firstRemote: 先请求网络，失败时回退缓存
    func handleFirstRemote(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor
    ) -> Observable<Any> {
        source
            .map { [cache] element -> Any in
                if let response = element as? Response {
                    cache.set(response, forKey: key, interceptor: interceptor)
                }
                return element
            }
            .catch { [cache] error -> Observable<Any> in
                if let cachedResponse = cache.get(forKey: key, maxAge: maxAge) {
                    return .just(cachedResponse)
                }
                return .error(error)
            }
    }

    /// onlyCache: 只读缓存，没有则 empty
    func handleOnlyCache(key: String, maxAge: TimeInterval) -> Observable<Any> {
        if let cachedResponse = cache.get(forKey: key, maxAge: maxAge) {
            return .just(cachedResponse)
        }
        return .empty()
    }

    /// ifCache: 有缓存用缓存，无缓存走网络
    func handleIfCache(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor
    ) -> Observable<Any> {
        if let cachedResponse = cache.get(forKey: key, maxAge: maxAge) {
            return .just(cachedResponse)
        }

        return source.map { [cache] element -> Any in
            if let response = element as? Response {
                cache.set(response, forKey: key, interceptor: interceptor)
            }
            return element
        }
    }

    /// lastCache: 返回缓存后静默更新网络（有缓存时只发射一次）
    func handleLastCache(
        source: Observable<some Any>,
        key: String,
        maxAge: TimeInterval,
        interceptor: any CacheInterceptor
    ) -> Observable<Any> {
        Observable<Any>.create { [cache] observer in
            if let cachedResponse = cache.get(forKey: key, maxAge: maxAge) {
                observer.onNext(cachedResponse)

                let disposable = source.subscribe(
                    onNext: { element in
                        if let response = element as? Response {
                            cache.set(response, forKey: key, interceptor: interceptor)
                        }
                    },
                    onError: { _ in
                        observer.onCompleted()
                    },
                    onCompleted: {
                        observer.onCompleted()
                    }
                )
                return disposable
            } else {
                let disposable = source.subscribe(
                    onNext: { element in
                        if let response = element as? Response {
                            cache.set(response, forKey: key, interceptor: interceptor)
                        }
                        observer.onNext(element)
                    },
                    onError: { error in
                        observer.onError(error)
                    },
                    onCompleted: {
                        observer.onCompleted()
                    }
                )
                return disposable
            }
        }
    }
}
