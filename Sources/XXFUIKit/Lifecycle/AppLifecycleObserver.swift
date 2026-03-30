//
//  AppLifecycleObserver.swift
//  xxf_ios
//  app 生命周期管理，支持多回调注册和取消订阅
//  Created by xxf on 18/6/2.
//

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

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

    #if canImport(AppKit)
    private var windowDidBecomeKeyCallbacks: [UUID: (NSWindow, [AnyHashable: Any]?) -> Void] = [:]
    private var windowDidResignKeyCallbacks: [UUID: (NSWindow, [AnyHashable: Any]?) -> Void] = [:]
    private var windowDidBecomeMainCallbacks: [UUID: (NSWindow, [AnyHashable: Any]?) -> Void] = [:]
    private var windowDidResignMainCallbacks: [UUID: (NSWindow, [AnyHashable: Any]?) -> Void] = [:]
    private var windowWillCloseCallbacks: [UUID: (NSWindow, [AnyHashable: Any]?) -> Void] = [:]
    #endif

    private var cancellables = Set<AnyCancellable>()

    public init() {
        let nc = NotificationCenter.default

        #if canImport(AppKit)
        // AppKit 生命周期
        nc.publisher(for: NSApplication.willFinishLaunchingNotification)
            .sink { [weak self] _ in self?.willFinishLaunchingCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

        nc.publisher(for: NSApplication.didFinishLaunchingNotification)
            .sink { [weak self] _ in self?.didFinishLaunchingCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

        nc.publisher(for: NSApplication.willTerminateNotification)
            .sink { [weak self] _ in self?.willTerminateCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

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
            .sink { [weak self] note in
                guard let window = note.object as? NSWindow else { return }
                self?.windowDidBecomeKeyCallbacks.values.forEach { $0(window, note.userInfo) }
            }
            .store(in: &cancellables)

        nc.publisher(for: NSWindow.didResignKeyNotification)
            .sink { [weak self] note in
                guard let window = note.object as? NSWindow else { return }
                self?.windowDidResignKeyCallbacks.values.forEach { $0(window, note.userInfo) }
            }
            .store(in: &cancellables)

        nc.publisher(for: NSWindow.didBecomeMainNotification)
            .sink { [weak self] note in
                guard let window = note.object as? NSWindow else { return }
                self?.windowDidBecomeMainCallbacks.values.forEach { $0(window, note.userInfo) }
            }
            .store(in: &cancellables)

        nc.publisher(for: NSWindow.didResignMainNotification)
            .sink { [weak self] note in
                guard let window = note.object as? NSWindow else { return }
                self?.windowDidResignMainCallbacks.values.forEach { $0(window, note.userInfo) }
            }
            .store(in: &cancellables)

        nc.publisher(for: NSWindow.willCloseNotification)
            .sink { [weak self] note in
                guard let window = note.object as? NSWindow else { return }
                self?.windowWillCloseCallbacks.values.forEach { $0(window, note.userInfo) }
            }
            .store(in: &cancellables)
        #endif

        #if canImport(UIKit)
        // UIKit 生命周期
        nc.publisher(for: UIApplication.didFinishLaunchingNotification)
            .sink { [weak self] _ in self?.didFinishLaunchingCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

        nc.publisher(for: UIApplication.willTerminateNotification)
            .sink { [weak self] _ in self?.willTerminateCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

        nc.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in self?.didBecomeActiveCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)

        nc.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in self?.didResignActiveCallbacks.values.forEach { $0() } }
            .store(in: &cancellables)
        #endif
    }

    deinit {
        cancellables.removeAll()
    }

    // MARK: - 订阅添加接口 (doOnXXX) 返回 UUID 以便取消订阅

    @discardableResult
    public func doOnWillFinishLaunching(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        willFinishLaunchingCallbacks[id] = callback
        return id
    }

    @discardableResult
    public func doOnDidFinishLaunching(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        didFinishLaunchingCallbacks[id] = callback
        return id
    }

    @discardableResult
    public func doOnWillTerminate(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        willTerminateCallbacks[id] = callback
        return id
    }

    @discardableResult
    public func doOnDidBecomeActive(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        didBecomeActiveCallbacks[id] = callback
        return id
    }

    @discardableResult
    public func doOnDidResignActive(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        didResignActiveCallbacks[id] = callback
        return id
    }

    @discardableResult
    public func doOnDidHide(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        didHideCallbacks[id] = callback
        return id
    }

    @discardableResult
    public func doOnDidUnhide(_ callback: @escaping () -> Void) -> UUID {
        let id = UUID()
        didUnhideCallbacks[id] = callback
        return id
    }

    #if canImport(AppKit)
    @discardableResult
    public func doOnWindowDidBecomeKey(_ callback: @escaping (NSWindow, [AnyHashable: Any]?) -> Void) -> UUID {
        let id = UUID()
        windowDidBecomeKeyCallbacks[id] = callback
        return id
    }

    @discardableResult
    public func doOnWindowDidResignKey(_ callback: @escaping (NSWindow, [AnyHashable: Any]?) -> Void) -> UUID {
        let id = UUID()
        windowDidResignKeyCallbacks[id] = callback
        return id
    }

    @discardableResult
    public func doOnWindowDidBecomeMain(_ callback: @escaping (NSWindow, [AnyHashable: Any]?) -> Void) -> UUID {
        let id = UUID()
        windowDidBecomeMainCallbacks[id] = callback
        return id
    }

    @discardableResult
    public func doOnWindowDidResignMain(_ callback: @escaping (NSWindow, [AnyHashable: Any]?) -> Void) -> UUID {
        let id = UUID()
        windowDidResignMainCallbacks[id] = callback
        return id
    }

    @discardableResult
    public func doOnWindowWillClose(_ callback: @escaping (NSWindow, [AnyHashable: Any]?) -> Void) -> UUID {
        let id = UUID()
        windowWillCloseCallbacks[id] = callback
        return id
    }
    #endif

    // MARK: - 取消订阅接口

    public func removeCallback(for id: UUID) {
        willFinishLaunchingCallbacks.removeValue(forKey: id)
        didFinishLaunchingCallbacks.removeValue(forKey: id)
        willTerminateCallbacks.removeValue(forKey: id)

        didBecomeActiveCallbacks.removeValue(forKey: id)
        didResignActiveCallbacks.removeValue(forKey: id)
        didHideCallbacks.removeValue(forKey: id)
        didUnhideCallbacks.removeValue(forKey: id)

        #if canImport(AppKit)
        windowDidBecomeKeyCallbacks.removeValue(forKey: id)
        windowDidResignKeyCallbacks.removeValue(forKey: id)
        windowDidBecomeMainCallbacks.removeValue(forKey: id)
        windowDidResignMainCallbacks.removeValue(forKey: id)
        windowWillCloseCallbacks.removeValue(forKey: id)
        #endif
    }
}
