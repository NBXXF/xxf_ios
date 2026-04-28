//
//  ContinuousTapGestureDetection.swift
//  xxf_ios
//
//  连续点击手势检测器
//  可用于监听任意组件，连续点击 N 次后触发回调，不影响原有事件分发
//
//  Created by Claude on 2023/03/31.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - 跨平台 View 类型别名

#if os(iOS)
public typealias CrossPlatformView = UIView
#elseif os(macOS)
public typealias CrossPlatformView = NSView
#endif

// MARK: - 连续点击手势检测器

/// 用于监听任意组件的连续点击手势检测器
///
/// 功能：
/// - 可附加到任意 View/NSView 上
/// - 在指定时间内、指定范围内连续点击达到指定次数后触发回调
/// - 不影响原有的事件分发（使用手势识别器或事件监听）
///
/// 使用方式：
/// ```swift
/// // 方式1：使用默认配置（5次点击、3秒内、44pt范围内）
/// let detector = ContinuousTapGestureDetection(targetView: myView) {
///     print("连续点击5次触发！")
/// }
///
/// // 方式2：自定义配置
/// let detector = ContinuousTapGestureDetection(
///     targetView: myView,
///     requiredTaps: 3,
///     maxDistance: 30,
///     maxInterval: 2,
///     onTrigger: {
///         print("3次快速点击触发！")
///     }
/// )
///
/// // 方式3：稍后设置回调
/// let detector = ContinuousTapGestureDetection(targetView: myView)
/// detector.onTrigger = {
///     print("触发了！")
/// }
///
/// // 方式4：指定点击区域（相对于 targetView 的坐标系）
/// let tapArea = CGRect(x: 0, y: 0, width: 100, height: 44)
/// let detector = ContinuousTapGestureDetection(
///     targetView: myView,
///     validArea: tapArea
/// ) {
///     print("在指定区域内点击触发！")
/// }
/// ```
///
/// 生命周期管理：
/// - 当 targetView 被释放时，检测器会自动停止工作
/// - 手动停止检测：调用 `stopDetection()`
/// - 重新开始检测：调用 `startDetection()`
public class ContinuousTapGestureDetection: @unchecked Sendable {

    // MARK: - 私有属性

    /// 目标视图（弱引用，避免循环引用）
    private weak var targetView: CrossPlatformView?

    /// 记录每次点击的时间戳，用于判断是否在指定时间间隔内
    private var tapTimestamps: [TimeInterval] = []

    /// 记录每次点击的位置，用于判断是否在指定范围内
    private var tapLocations: [CGPoint] = []

    /// 触发所需的连续点击次数
    private let requiredTaps: Int

    /// 允许的最大点击距离偏移（pt）
    private let maxDistance: CGFloat

    /// 允许的最大时间间隔（秒）
    private let maxInterval: TimeInterval

    /// 有效的点击区域（nil 表示不限制区域，相对于 targetView 的坐标系）
    private let validArea: CGRect?

    /// 触发回调
    public var onTrigger: (() -> Void)?

    /// 是否正在监听
    private var isListening = false

    #if os(iOS)
    /// iOS: 手势识别器
    private var tapGestureRecognizer: UITapGestureRecognizer?
    #elseif os(macOS)
    /// macOS: 点击事件监视器
    private var clickMonitor: Any?
    #endif

    // MARK: - 初始化

    /// 初始化连续点击检测器
    /// - Parameters:
    ///   - targetView: 要监听的目标视图
    ///   - requiredTaps: 触发所需的连续点击次数，默认 5 次
    ///   - maxDistance: 允许的最大点击距离偏移（pt），默认 44pt
    ///   - maxInterval: 允许的最大时间间隔（秒），默认 3 秒
    ///   - onTrigger: 触发时的回调（可选）
    public init(
        targetView: CrossPlatformView,
        requiredTaps: Int = 5,
        maxDistance: CGFloat = 44,
        maxInterval: TimeInterval = 3,
        onTrigger: (() -> Void)? = nil
    ) {
        self.targetView = targetView
        self.requiredTaps = requiredTaps
        self.maxDistance = maxDistance
        self.maxInterval = maxInterval
        self.validArea = nil
        self.onTrigger = onTrigger
        startDetection()
    }

    /// 初始化连续点击检测器（支持指定点击区域）
    /// - Parameters:
    ///   - targetView: 要监听的目标视图
    ///   - validArea: 有效的点击区域，只有在这个区域内点击才生效（相对于 targetView 的坐标系）
    ///   - requiredTaps: 触发所需的连续点击次数，默认 5 次
    ///   - maxDistance: 允许的最大点击距离偏移（pt），默认 44pt
    ///   - maxInterval: 允许的最大时间间隔（秒），默认 3 秒
    ///   - onTrigger: 触发时的回调（可选）
    public init(
        targetView: CrossPlatformView,
        validArea: CGRect,
        requiredTaps: Int = 5,
        maxDistance: CGFloat = 44,
        maxInterval: TimeInterval = 3,
        onTrigger: (() -> Void)? = nil
    ) {
        self.targetView = targetView
        self.requiredTaps = requiredTaps
        self.maxDistance = maxDistance
        self.maxInterval = maxInterval
        self.validArea = validArea
        self.onTrigger = onTrigger
        startDetection()
    }

    deinit {
        stopDetection()
    }

    // MARK: - 开始/停止检测

    /// 开始监听点击事件
    ///
    /// 默认在初始化时自动调用，也可以手动调用以重新开始监听
    public func startDetection() {
        guard !isListening, let targetView = targetView else { return }
        isListening = true

        #if os(iOS)
        setupIOSGesture(targetView)
        #elseif os(macOS)
        setupMacOSMonitor(targetView)
        #endif
    }

    /// 停止监听点击事件
    ///
    /// 停止后不再响应点击检测，但保留当前配置
    /// 可以调用 `startDetection()` 重新开始监听
    public func stopDetection() {
        guard isListening else { return }
        isListening = false

        #if os(iOS)
        if let gesture = tapGestureRecognizer {
            targetView?.removeGestureRecognizer(gesture)
            tapGestureRecognizer = nil
        }
        #elseif os(macOS)
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
        #endif
    }

    #if os(iOS)
    // MARK: - iOS 手势设置

    private func setupIOSGesture(_ view: UIView) {
        // 创建手势识别器，使用自定义的 shouldReceiveTouch 来处理事件
        // UIKit 手势 API 全部 @MainActor 隔离；本类只在 UI 线程构造，这里用
        // assumeIsolated 绕开 Swift 6 的隔离检查，运行时首次访问仍必须在主线程。
        MainActor.assumeIsolated {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
            gesture.cancelsTouchesInView = false  // 不取消其他触摸事件，保证原有事件分发
            gesture.delaysTouchesBegan = false    // 不延迟触摸开始
            gesture.delaysTouchesEnded = false    // 不延迟触摸结束
            gesture.numberOfTapsRequired = 1      // 每次只识别单击
            gesture.numberOfTouchesRequired = 1   // 单指触摸

            view.addGestureRecognizer(gesture)
            self.tapGestureRecognizer = gesture
        }
    }

    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        handleTap(at: location)
    }

    #elseif os(macOS)
    // MARK: - macOS 事件监视器设置

    private func setupMacOSMonitor(_ view: NSView) {
        // 使用本地事件监视器监听鼠标点击
        clickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseUp]) { [weak self] event in
            guard let self = self, let targetView = self.targetView else { return event }

            // 先从 NSEvent 里取出 Sendable 的 NSPoint，避免把非 Sendable 的 event
            // 送进下面的 @Sendable assumeIsolated 闭包触发数据竞争警告。
            let locationInWindow = event.locationInWindow

            // NSView 的 convert / bounds 是 @MainActor，这里 monitor 闭包在主线程回调。
            MainActor.assumeIsolated {
                let locationInView = targetView.convert(locationInWindow, from: nil)
                if targetView.bounds.contains(locationInView) {
                    self.handleTap(at: locationInView)
                }
            }

            return event  // 返回事件，不影响原有事件分发
        }
    }
    #endif

    // MARK: - 点击处理逻辑

    /// 处理单次点击
    /// - Parameter location: 点击位置（相对于 targetView 的坐标系）
    ///
    /// 逻辑说明：
    /// 1. 如果指定了 validArea，检查点击是否在区域内
    /// 2. 记录当前点击的时间和位置
    /// 3. 保持数组长度不超过 requiredTaps（滑动窗口）
    /// 4. 检查是否满足触发条件：
    ///    - 点击次数达到 requiredTaps
    ///    - 所有点击在 maxInterval 时间内完成
    ///    - 所有点击位置在 maxDistance 范围内
    private func handleTap(at location: CGPoint) {
        // 检查是否在有效区域内（如果指定了区域）
        if let validArea = validArea, !validArea.contains(location) {
            return
        }

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
            onTrigger?()
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

    // MARK: - 重置

    /// 重置检测状态
    ///
    /// 清空所有记录的点击时间和位置，重新开始计数
    public func reset() {
        tapTimestamps.removeAll()
        tapLocations.removeAll()
    }
}

// MARK: - 链式调用支持（可选）

extension ContinuousTapGestureDetection {

    /// 设置触发回调（支持链式调用）
    /// - Parameter callback: 触发时的回调
    /// - Returns: self，支持链式调用
    @discardableResult
    public func setOnTrigger(_ callback: @escaping () -> Void) -> Self {
        self.onTrigger = callback
        return self
    }
}

// MARK: - UIView/NSView 扩展（便捷方法）

#if os(iOS)
public extension UIView {

    /// 添加连续点击检测
    /// - Parameters:
    ///   - taps: 触发所需的连续点击次数，默认 5 次
    ///   - distance: 允许的最大点击距离偏移（pt），默认 44pt
    ///   - interval: 允许的最大时间间隔（秒），默认 3 秒
    ///   - action: 触发时的回调
    /// - Returns: 创建的检测器实例，可用于后续控制
    @discardableResult
    func addContinuousTapDetection(
        taps: Int = 5,
        distance: CGFloat = 44,
        interval: TimeInterval = 3,
        action: @escaping () -> Void
    ) -> ContinuousTapGestureDetection {
        return ContinuousTapGestureDetection(
            targetView: self,
            requiredTaps: taps,
            maxDistance: distance,
            maxInterval: interval,
            onTrigger: action
        )
    }
}

#elseif os(macOS)
public extension NSView {

    /// 添加连续点击检测
    /// - Parameters:
    ///   - taps: 触发所需的连续点击次数，默认 5 次
    ///   - distance: 允许的最大点击距离偏移（pt），默认 44pt
    ///   - interval: 允许的最大时间间隔（秒），默认 3 秒
    ///   - action: 触发时的回调
    /// - Returns: 创建的检测器实例，可用于后续控制
    @discardableResult
    func addContinuousTapDetection(
        taps: Int = 5,
        distance: CGFloat = 44,
        interval: TimeInterval = 3,
        action: @escaping () -> Void
    ) -> ContinuousTapGestureDetection {
        return ContinuousTapGestureDetection(
            targetView: self,
            requiredTaps: taps,
            maxDistance: distance,
            maxInterval: interval,
            onTrigger: action
        )
    }
}
#endif
