//
//  TouchDetectingWindow.swift
//  xxf_ios
//
//  连续点击检测窗口
//  用于在指定时间内、指定范围内连续点击 N 次后触发日志页面
//
//  使用方式：
//  1. 在 SceneDelegate 中使用 TouchDetectingWindow 替换 UIWindow
//  2. 默认配置：5次点击、3秒内、44pt范围内
//  3. 触发后会以 pageSheet 样式弹出日志页面
//
//  Created by xxf on 11/14.
//

#if os(iOS)
import SwiftUI
import UIKit
#elseif os(macOS)
import AppKit
import SwiftUI
#endif

// MARK: - 跨平台 Window 类型别名

#if os(iOS)
public typealias BaseWindow = UIWindow
#elseif os(macOS)
public typealias BaseWindow = NSWindow
#endif

// MARK: - TouchDetectingWindow

/// 支持连续点击检测的自定义 Window
///
/// 功能：
/// - 监听用户的点击事件
/// - 在指定时间内、指定范围内连续点击达到指定次数后触发回调
/// - 默认触发后弹出日志查看页面（LogViewController）
///
/// 支持的 ViewController 层级：
/// - UITabBarController
/// - UINavigationController
/// - UISplitViewController (iPad)
/// - UIPageViewController
/// - 多层 present 的 ViewController
/// - UIAlertController (会跳过，在其 presenting VC 上弹出)
open class TouchDetectingWindow<WindowType: BaseWindow>: BaseWindow {

    // MARK: - 私有属性

    /// 记录每次点击的时间戳，用于判断是否在指定时间间隔内
    private var tapTimestamps: [TimeInterval] = []

    /// 记录每次点击的位置，用于判断是否在指定范围内
    private var tapLocations: [CGPoint] = []

    /// 触发所需的连续点击次数（默认 5 次）
    private let requiredTaps: Int

    /// 允许的最大点击距离偏移（默认 44pt，约一个手指大小）
    private let maxDistance: CGFloat

    /// 允许的最大时间间隔（默认 3 秒）
    private let maxInterval: TimeInterval

    // MARK: - 初始化

    #if os(iOS)
    /// iOS 初始化方法
    /// - Parameters:
    ///   - windowScene: UIWindowScene 实例
    ///   - requiredTaps: 触发所需的连续点击次数，默认 5 次
    ///   - maxDistance: 允许的最大点击距离偏移（pt），默认 44pt
    ///   - maxInterval: 允许的最大时间间隔（秒），默认 3 秒
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

    /// 重写 sendEvent 以捕获所有触摸事件
    /// - Parameter event: UIEvent 事件
    /// - Note: 调用 super.sendEvent 保证不阻塞原有事件传递
    override public func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        guard let touches = event.allTouches else { return }
        // 只处理触摸结束事件（手指抬起时）
        for touch in touches where touch.phase == .ended {
            handleTap(at: touch.location(in: self))
        }
    }

    #elseif os(macOS)
    /// macOS 初始化方法
    /// - Parameters:
    ///   - contentRect: 窗口内容区域
    ///   - style: 窗口样式
    ///   - backingStoreType: 后备存储类型
    ///   - flag: 是否延迟创建
    ///   - requiredTaps: 触发所需的连续点击次数，默认 5 次
    ///   - maxDistance: 允许的最大点击距离偏移（pt），默认 44pt
    ///   - maxInterval: 允许的最大时间间隔（秒），默认 3 秒
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

    /// 重写 mouseUp 以捕获鼠标点击事件
    /// - Parameter event: NSEvent 事件
    override public func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        handleTap(at: event.locationInWindow)
    }
    #endif

    // MARK: - 点击处理逻辑

    /// 处理单次点击
    /// - Parameter location: 点击位置
    ///
    /// 逻辑说明：
    /// 1. 记录当前点击的时间和位置
    /// 2. 保持数组长度不超过 requiredTaps（滑动窗口）
    /// 3. 检查是否满足触发条件：
    ///    - 点击次数达到 requiredTaps
    ///    - 所有点击在 maxInterval 时间内完成
    ///    - 所有点击位置在 maxDistance 范围内
    private func handleTap(at location: CGPoint) {
        let now = Date().timeIntervalSince1970

        // 记录本次点击
        tapTimestamps.append(now)
        tapLocations.append(location)

        // 滑动窗口：只保留最近的 requiredTaps 次点击记录
        if tapTimestamps.count > requiredTaps {
            tapTimestamps.removeFirst()
            tapLocations.removeFirst()
        }

        // 检查是否满足触发条件
        if tapTimestamps.count == requiredTaps,           // 条件1: 点击次数足够
           now - tapTimestamps.first! <= maxInterval,     // 条件2: 在时间间隔内
           areLocationsCloseEnough()                       // 条件3: 在距离范围内
        {
            // 清空记录，防止重复触发
            tapTimestamps.removeAll()
            tapLocations.removeAll()

            // 触发回调
            onTouchDetecting()
        }
    }

    /// 检查所有点击位置是否在允许的范围内
    /// - Returns: 如果所有点击位置与第一次点击的距离都在 maxDistance 内，返回 true
    ///
    /// 计算方式：以第一次点击位置为圆心，检查后续点击是否都在半径为 maxDistance 的圆内
    private func areLocationsCloseEnough() -> Bool {
        guard let first = tapLocations.first else { return false }
        return tapLocations.allSatisfy { loc in
            let dx = loc.x - first.x
            let dy = loc.y - first.y
            let distance = sqrt(dx * dx + dy * dy)
            return distance <= maxDistance
        }
    }

    // MARK: - 触发回调

    /// 连续点击检测成功后的回调
    /// - Note: 子类可以重写此方法自定义触发行为
    /// - Note: 默认实现会弹出 LogViewController
    open func onTouchDetecting() {
        DispatchQueue.main.async {
            self.showLogVC()
        }
    }

    // MARK: - 弹出日志页面

    /// 弹出日志查看页面
    ///
    /// iOS：以 pageSheet 样式 modal 弹出，支持下滑关闭
    /// macOS：以模态窗口形式弹出
    private func showLogVC() {
        #if os(iOS)
        guard let rootVC = self.rootViewController else { return }

        // 创建日志页面并包装在 NavigationController 中
        let logVC = LogViewController()
        let nav = UINavigationController(rootViewController: logVC)

        // 使用 pageSheet 样式，支持下滑关闭，视觉效果更好
        nav.modalPresentationStyle = .pageSheet

        // 找到当前最顶层的 ViewController 进行 present
        let topVC = findTopViewController(from: rootVC)
        topVC.present(nav, animated: true)

        #elseif os(macOS)
        guard let contentVC = self.contentViewController else { return }
        let logVC = LogViewController()
        contentVC.presentAsModalWindow(logVC)
        #endif
    }

    #if os(iOS)
    // MARK: - 查找最顶层 ViewController

    /// 递归查找当前最顶层的 ViewController
    ///
    /// 支持的 ViewController 容器类型：
    /// - UITabBarController: 获取 selectedViewController
    /// - UINavigationController: 获取 visibleViewController
    /// - UISplitViewController: 优先获取 secondary/detail VC
    /// - UIPageViewController: 获取当前显示的页面
    /// - presentedViewController: 递归查找到最顶层
    ///
    /// 特殊处理：
    /// - UIAlertController: 跳过，因为无法在 Alert 上 present 其他 VC
    ///
    /// - Parameter vc: 起始 ViewController
    /// - Returns: 最顶层的 ViewController
    private func findTopViewController(from vc: UIViewController) -> UIViewController {

        // 1. 优先检查是否有 presented 的 VC（处理 modal 层级）
        if let presented = vc.presentedViewController {
            // 特殊处理：UIAlertController 不支持在其上 present 其他 VC
            // 所以如果遇到 Alert/ActionSheet，返回其 presenting VC
            if presented is UIAlertController {
                return vc
            }
            // 递归查找 presented 链的最顶层
            return findTopViewController(from: presented)
        }

        // 2. UITabBarController：从当前选中的 Tab 继续查找
        if let tabBar = vc as? UITabBarController,
           let selected = tabBar.selectedViewController
        {
            return findTopViewController(from: selected)
        }

        // 3. UINavigationController：从当前可见的 VC 继续查找
        if let nav = vc as? UINavigationController,
           let visible = nav.visibleViewController
        {
            return findTopViewController(from: visible)
        }

        // 4. UISplitViewController：优先从 secondary (detail) 侧查找
        //    适用于 iPad 分屏场景
        if let split = vc as? UISplitViewController {
            if #available(iOS 14.0, *) {
                // iOS 14+ 使用新的 viewController(for:) API
                if let secondary = split.viewController(for: .secondary) {
                    return findTopViewController(from: secondary)
                }
                if let primary = split.viewController(for: .primary) {
                    return findTopViewController(from: primary)
                }
            } else {
                // iOS 14 以下使用 viewControllers 数组
                // index 1 是 detail/secondary，index 0 是 primary/master
                if split.viewControllers.count > 1 {
                    return findTopViewController(from: split.viewControllers[1])
                }
                if let first = split.viewControllers.first {
                    return findTopViewController(from: first)
                }
            }
        }

        // 5. UIPageViewController：从当前显示的页面继续查找
        if let page = vc as? UIPageViewController,
           let current = page.viewControllers?.first
        {
            return findTopViewController(from: current)
        }

        // 6. 普通 ViewController：直接返回
        return vc
    }
    #endif
}
