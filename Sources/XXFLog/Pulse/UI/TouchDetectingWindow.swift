//
//  TouchDetectingWindow.swift
//  xxf_ios
//  连续点击跳转日志
//  Created by xxf on 11/14.
//

#if os(iOS)
import SwiftUI
import UIKit
#elseif os(macOS)
import AppKit
import SwiftUI
#endif

#if os(iOS)
public typealias BaseWindow = UIWindow
#elseif os(macOS)
public typealias BaseWindow = NSWindow
#endif

open class TouchDetectingWindow<WindowType: BaseWindow>: BaseWindow {
    private var tapTimestamps: [TimeInterval] = []
    private var tapLocations: [CGPoint] = []

    private let requiredTaps: Int
    private let maxDistance: CGFloat
    private let maxInterval: TimeInterval

    // MARK: - 初始化

    #if os(iOS)
    public init(windowScene: UIWindowScene,
                requiredTaps: Int = 5,
                maxDistance: CGFloat = 44,
                maxInterval: TimeInterval = 3)
    {
        self.requiredTaps = requiredTaps
        self.maxDistance = maxDistance
        self.maxInterval = maxInterval
        super.init(windowScene: windowScene)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // 捕获点击事件
    override public func sendEvent(_ event: UIEvent) {
        super.sendEvent(event) // 保证不阻塞原有事件
        guard let touches = event.allTouches else { return }
        for touch in touches where touch.phase == .ended {
            handleTap(at: touch.location(in: self))
        }
    }

    #elseif os(macOS)
    public init(contentRect: NSRect,
                styleMask style: NSWindow.StyleMask = [.titled, .closable, .resizable],
                backing backingStoreType: NSWindow.BackingStoreType = .buffered,
                defer flag: Bool = false,
                requiredTaps: Int = 5,
                maxDistance: CGFloat = 44,
                maxInterval: TimeInterval = 3)
    {
        self.requiredTaps = requiredTaps
        self.maxDistance = maxDistance
        self.maxInterval = maxInterval
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    }

    // 捕获点击事件
    override public func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        handleTap(at: event.locationInWindow)
    }
    #endif

    // MARK: - 处理点击逻辑

    private func handleTap(at location: CGPoint) {
        let now = Date().timeIntervalSince1970
        tapTimestamps.append(now)
        tapLocations.append(location)

        if tapTimestamps.count > requiredTaps {
            tapTimestamps.removeFirst()
            tapLocations.removeFirst()
        }

        if tapTimestamps.count == requiredTaps,
           now - tapTimestamps.first! <= maxInterval,
           areLocationsCloseEnough()
        {
            tapTimestamps.removeAll()
            tapLocations.removeAll()

            onTouchDetecting()
        }
    }

    private func areLocationsCloseEnough() -> Bool {
        guard let first = tapLocations.first else { return false }
        return tapLocations.allSatisfy { loc in
            let dx = loc.x - first.x
            let dy = loc.y - first.y
            return sqrt(dx*dx + dy*dy) <= maxDistance
        }
    }

    // MARK: - 检查到

    open func onTouchDetecting() {
        DispatchQueue.main.async {
            self.showLogVC()
        }
    }

    // MARK: - 弹出 LogViewController

    private func showLogVC() {
        #if os(iOS)
        guard let rootVC = self.rootViewController else { return }
        let logVC = LogViewController()
        let nav = UINavigationController(rootViewController: logVC)
        nav.modalPresentationStyle = .fullScreen

        // 找到最顶层的 ViewController 进行 present
        let topVC = findTopViewController(from: rootVC)
        topVC.present(nav, animated: true)
        #elseif os(macOS)
        guard let contentVC = self.contentViewController else { return }
        let logVC = LogViewController()
        contentVC.presentAsModalWindow(logVC)
        #endif
    }

    #if os(iOS)
    /// 递归查找最顶层的 ViewController
    private func findTopViewController(from vc: UIViewController) -> UIViewController {
        // 优先检查 presented
        if let presented = vc.presentedViewController {
            return findTopViewController(from: presented)
        }

        // TabBarController：从选中的 VC 查找
        if let tabBar = vc as? UITabBarController,
           let selected = tabBar.selectedViewController
        {
            return findTopViewController(from: selected)
        }

        // NavigationController：从 visibleViewController 查找
        if let nav = vc as? UINavigationController,
           let visible = nav.visibleViewController
        {
            return findTopViewController(from: visible)
        }

        return vc
    }
    #endif
}
