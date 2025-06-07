//
//  AppLifecycleObserver.swift
//  xxf_ios
//  app 生命周期管理
//  Created by xxf on 2025/6/2.
//

import AppKit
import Combine

public final class AppLifecycleObserver {
    // MARK: - 应用相关事件回调

    public var onWillFinishLaunching: (() -> Void)?
    public var onDidFinishLaunching: (() -> Void)?
    public var onWillTerminate: (() -> Void)?

    public var onDidBecomeActive: (() -> Void)?
    public var onDidResignActive: (() -> Void)?
    public var onDidHide: (() -> Void)?
    public var onDidUnhide: (() -> Void)?

    // MARK: - 窗口相关事件回调

    public var onWindowDidBecomeKey: ((Notification) -> Void)?
    public var onWindowDidResignKey: ((Notification) -> Void)?
    public var onWindowDidBecomeMain: ((Notification) -> Void)?
    public var onWindowDidResignMain: ((Notification) -> Void)?

    private var cancellables = Set<AnyCancellable>()

    init() {
        let nc = NotificationCenter.default

        // 应用生命周期
        nc.publisher(for: NSApplication.willFinishLaunchingNotification)
            .sink { [weak self] _ in self?.onWillFinishLaunching?() }
            .store(in: &cancellables)

        nc.publisher(for: NSApplication.didFinishLaunchingNotification)
            .sink { [weak self] _ in self?.onDidFinishLaunching?() }
            .store(in: &cancellables)

        nc.publisher(for: NSApplication.willTerminateNotification)
            .sink { [weak self] _ in self?.onWillTerminate?() }
            .store(in: &cancellables)

        // 应用激活/隐藏
        nc.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in self?.onDidBecomeActive?() }
            .store(in: &cancellables)

        nc.publisher(for: NSApplication.didResignActiveNotification)
            .sink { [weak self] _ in self?.onDidResignActive?() }
            .store(in: &cancellables)

        nc.publisher(for: NSApplication.didHideNotification)
            .sink { [weak self] _ in self?.onDidHide?() }
            .store(in: &cancellables)

        nc.publisher(for: NSApplication.didUnhideNotification)
            .sink { [weak self] _ in self?.onDidUnhide?() }
            .store(in: &cancellables)

        // 窗口相关事件
        nc.publisher(for: NSWindow.didBecomeKeyNotification)
            .sink { [weak self] note in self?.onWindowDidBecomeKey?(note) }
            .store(in: &cancellables)

        nc.publisher(for: NSWindow.didResignKeyNotification)
            .sink { [weak self] note in self?.onWindowDidResignKey?(note) }
            .store(in: &cancellables)

        nc.publisher(for: NSWindow.didBecomeMainNotification)
            .sink { [weak self] note in self?.onWindowDidBecomeMain?(note) }
            .store(in: &cancellables)

        nc.publisher(for: NSWindow.didResignMainNotification)
            .sink { [weak self] note in self?.onWindowDidResignMain?(note) }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.removeAll()
    }
}
