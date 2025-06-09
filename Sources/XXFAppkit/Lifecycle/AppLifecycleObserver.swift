//
//  AppLifecycleObserver.swift
//  xxf_ios
//  app 生命周期管理，支持多回调注册和取消订阅
//  Created by xxf on /6/2.
//

import AppKit
import Combine

public final class AppLifecycleObserver {
    // MARK: - 应用相关事件回调

    private var willFinishLaunchingCallbacks: [UUID: () -> Void] = [:]
    private var didFinishLaunchingCallbacks: [UUID: () -> Void] = [:]
    private var willTerminateCallbacks: [UUID: () -> Void] = [:]

    private var didBecomeActiveCallbacks: [UUID: () -> Void] = [:]
    private var didResignActiveCallbacks: [UUID: () -> Void] = [:]
    private var didHideCallbacks: [UUID: () -> Void] = [:]
    private var didUnhideCallbacks: [UUID: () -> Void] = [:]

    // MARK: - 窗口相关事件回调

    private var windowDidBecomeKeyCallbacks: [UUID: (Notification) -> Void] = [:]
    private var windowDidResignKeyCallbacks: [UUID: (Notification) -> Void] = [:]
    private var windowDidBecomeMainCallbacks: [UUID: (Notification) -> Void] = [:]
    private var windowDidResignMainCallbacks: [UUID: (Notification) -> Void] = [:]

    private var cancellables = Set<AnyCancellable>()

    public init() {
        let nc = NotificationCenter.default

        // 应用生命周期
        nc.publisher(for: NSApplication.willFinishLaunchingNotification)
            .sink { [weak self] _ in self?.willFinishLaunchingCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

        nc.publisher(for: NSApplication.didFinishLaunchingNotification)
            .sink { [weak self] _ in self?.didFinishLaunchingCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

        nc.publisher(for: NSApplication.willTerminateNotification)
            .sink { [weak self] _ in self?.willTerminateCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

        // 应用激活/隐藏
        nc.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in self?.didBecomeActiveCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

        nc.publisher(for: NSApplication.didResignActiveNotification)
            .sink { [weak self] _ in self?.didResignActiveCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

        nc.publisher(for: NSApplication.didHideNotification)
            .sink { [weak self] _ in self?.didHideCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

        nc.publisher(for: NSApplication.didUnhideNotification)
            .sink { [weak self] _ in self?.didUnhideCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

        // 窗口相关事件
        nc.publisher(for: NSWindow.didBecomeKeyNotification)
            .sink { [weak self] note in self?.windowDidBecomeKeyCallbacks.values.forEach { $0(note) } }
            .store(in: &cancellables)

        nc.publisher(for: NSWindow.didResignKeyNotification)
            .sink { [weak self] note in self?.windowDidResignKeyCallbacks.values.forEach { $0(note) } }
            .store(in: &cancellables)

        nc.publisher(for: NSWindow.didBecomeMainNotification)
            .sink { [weak self] note in self?.windowDidBecomeMainCallbacks.values.forEach { $0(note) } }
            .store(in: &cancellables)

        nc.publisher(for: NSWindow.didResignMainNotification)
            .sink { [weak self] note in self?.windowDidResignMainCallbacks.values.forEach { $0(note) } }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - 订阅添加接口 (doOnXXX) 返回 UUID 以便取消订阅

    /// 添加一个回调，当应用即将完成启动时被调用。
    /// - Parameter callback: 无参数、无返回值的闭包，会在 `NSApplication.willFinishLaunchingNotification` 触发时调用。
    /// - Returns: 返回一个 UUID 标识符，用于后续取消订阅。
    @discardableResult
    public func doOnWillFinishLaunching(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        willFinishLaunchingCallbacks[id] = callback
        return id
    }

    /// 添加一个回调，当应用完成启动时被调用。
    /// - Parameter callback: 无参数、无返回值的闭包，会在 `NSApplication.didFinishLaunchingNotification` 触发时调用。
    /// - Returns: 返回一个 UUID 标识符，用于后续取消订阅。
    @discardableResult
    public func doOnDidFinishLaunching(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        didFinishLaunchingCallbacks[id] = callback
        return id
    }

    /// 添加一个回调，当应用即将终止时被调用。
    /// - Parameter callback: 无参数、无返回值的闭包，会在 `NSApplication.willTerminateNotification` 触发时调用。
    /// - Returns: 返回一个 UUID 标识符，用于后续取消订阅。
    @discardableResult
    public func doOnWillTerminate(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        willTerminateCallbacks[id] = callback
        return id
    }

    /// 添加一个回调，当应用变为激活状态时被调用。
    /// - Parameter callback: 无参数、无返回值的闭包，会在 `NSApplication.didBecomeActiveNotification` 触发时调用。
    /// - Returns: 返回一个 UUID 标识符，用于后续取消订阅。
    @discardableResult
    public func doOnDidBecomeActive(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        didBecomeActiveCallbacks[id] = callback
        return id
    }

    /// 添加一个回调，当应用失去激活状态时被调用。
    /// - Parameter callback: 无参数、无返回值的闭包，会在 `NSApplication.didResignActiveNotification` 触发时调用。
    /// - Returns: 返回一个 UUID 标识符，用于后续取消订阅。
    @discardableResult
    public func doOnDidResignActive(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        didResignActiveCallbacks[id] = callback
        return id
    }

    /// 添加一个回调，当应用被隐藏时被调用。
    /// - Parameter callback: 无参数、无返回值的闭包，会在 `NSApplication.didHideNotification` 触发时调用。
    /// - Returns: 返回一个 UUID 标识符，用于后续取消订阅。
    @discardableResult
    public func doOnDidHide(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        didHideCallbacks[id] = callback
        return id
    }

    /// 添加一个回调，当应用从隐藏状态恢复时被调用。
    /// - Parameter callback: 无参数、无返回值的闭包，会在 `NSApplication.didUnhideNotification` 触发时调用。
    /// - Returns: 返回一个 UUID 标识符，用于后续取消订阅。
    @discardableResult
    public func doOnDidUnhide(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        didUnhideCallbacks[id] = callback
        return id
    }

    /// 添加一个回调，当任意窗口成为 Key 窗口时被调用。
    /// - Parameter callback: 带通知参数的闭包，会在 `NSWindow.didBecomeKeyNotification` 触发时调用，通知中包含相关窗口信息。
    /// - Returns: 返回一个 UUID 标识符，用于后续取消订阅。
    @discardableResult
    public func doOnWindowDidBecomeKey(_ callback: @escaping (Notification) -> Void) -> UUID {
        let id = UUID()
        windowDidBecomeKeyCallbacks[id] = callback
        return id
    }

    /// 添加一个回调，当任意窗口失去 Key 窗口时被调用。
    /// - Parameter callback: 带通知参数的闭包，会在 `NSWindow.didResignKeyNotification` 触发时调用，通知中包含相关窗口信息。
    /// - Returns: 返回一个 UUID 标识符，用于后续取消订阅。
    @discardableResult
    public func doOnWindowDidResignKey(_ callback: @escaping (Notification) -> Void) -> UUID {
        let id = UUID()
        windowDidResignKeyCallbacks[id] = callback
        return id
    }

    /// 添加一个回调，当任意窗口成为 Main 窗口时被调用。
    /// - Parameter callback: 带通知参数的闭包，会在 `NSWindow.didBecomeMainNotification` 触发时调用，通知中包含相关窗口信息。
    /// - Returns: 返回一个 UUID 标识符，用于后续取消订阅。
    @discardableResult
    public func doOnWindowDidBecomeMain(_ callback: @escaping (Notification) -> Void) -> UUID {
        let id = UUID()
        windowDidBecomeMainCallbacks[id] = callback
        return id
    }

    /// 添加一个回调，当任意窗口失去 Main 窗口时被调用。
    /// - Parameter callback: 带通知参数的闭包，会在 `NSWindow.didResignMainNotification` 触发时调用，通知中包含相关窗口信息。
    /// - Returns: 返回一个 UUID 标识符，用于后续取消订阅。
    @discardableResult
    public func doOnWindowDidResignMain(_ callback: @escaping (Notification) -> Void) -> UUID {
        let id = UUID()
        windowDidResignMainCallbacks[id] = callback
        return id
    }

    // MARK: - 取消订阅接口

    /// 根据回调标识取消应用生命周期事件订阅
    /// - Parameter id: 订阅时返回的 UUID
    public func removeCallback(for id: UUID) {
        willFinishLaunchingCallbacks.removeValue(forKey: id)
        didFinishLaunchingCallbacks.removeValue(forKey: id)
        willTerminateCallbacks.removeValue(forKey: id)

        didBecomeActiveCallbacks.removeValue(forKey: id)
        didResignActiveCallbacks.removeValue(forKey: id)
        didHideCallbacks.removeValue(forKey: id)
        didUnhideCallbacks.removeValue(forKey: id)

        windowDidBecomeKeyCallbacks.removeValue(forKey: id)
        windowDidResignKeyCallbacks.removeValue(forKey: id)
        windowDidBecomeMainCallbacks.removeValue(forKey: id)
        windowDidResignMainCallbacks.removeValue(forKey: id)
    }
}
