//
//  RxBus.swift
//  xxf_ios
//
//  Created by xxf on 6/29.
//

import Foundation
import RxRelay
import RxSwift

public final class RxBus {
    public nonisolated(unsafe) static let shared = RxBus()
    private init() {}

    private let relay = PublishRelay<Any>()
    private var stickyMap = [String: Any]()
    private let lock = NSRecursiveLock()

    // MARK: - 普通事件

    public func post<T>(_ event: T) {
        relay.accept(event)
    }

    public func observe<T>(_: T.Type) -> Observable<T> {
        return relay
            .compactMap { $0 as? T }
            .asObservable()
    }

    // MARK: - Sticky（黏性事件）

    public func postSticky<T>(_ event: T) {
        let key = "\(T.self)"
        lock.lock(); defer { lock.unlock() }
        stickyMap[key] = event
        post(event)
    }

    public func observeSticky<T>(_: T.Type) -> Observable<T> {
        let key = "\(T.self)"
        lock.lock()
        let sticky = stickyMap[key] as? T
        lock.unlock()

        let stream = observe(T.self)
        if let sticky = sticky {
            return Observable.concat([Observable.just(sticky), stream])
        } else {
            return stream
        }
    }

    public func removeSticky<T>(_: T.Type) {
        lock.lock(); defer { lock.unlock() }
        stickyMap.removeValue(forKey: "\(T.self)")
    }
}
