import Foundation

// MARK: - 性能报告

/// 性能报告数据
public struct PerformanceReport: Sendable {
    public let cpuUsage: Double
    public let fps: Int
    public let memoryUsed: UInt64
    public let memoryTotal: UInt64

    public init(cpuUsage: Double, fps: Int, memoryUsed: UInt64, memoryTotal: UInt64) {
        self.cpuUsage = cpuUsage
        self.fps = fps
        self.memoryUsed = memoryUsed
        self.memoryTotal = memoryTotal
    }
}

// MARK: - 显示选项

/// 性能监控显示选项
public struct PerformanceDisplayOptions: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// FPS 和 CPU
    public static let performance = PerformanceDisplayOptions(rawValue: 1 << 0)
    /// 内存使用
    public static let memory = PerformanceDisplayOptions(rawValue: 1 << 1)
    /// 应用版本
    public static let application = PerformanceDisplayOptions(rawValue: 1 << 2)
    /// 设备型号
    public static let device = PerformanceDisplayOptions(rawValue: 1 << 3)
    /// 系统版本
    public static let system = PerformanceDisplayOptions(rawValue: 1 << 4)
    /// 默认: performance + application + system
    public static let `default`: PerformanceDisplayOptions = [.performance, .application, .system]
    /// 全部
    public static let all: PerformanceDisplayOptions = [.performance, .memory, .application, .device, .system]
}

// MARK: - 显示样式

#if canImport(UIKit)
import UIKit

/// 性能监控悬浮窗样式
public enum PerformanceViewStyle: Sendable {
    case dark
    case light
    case custom(
        backgroundColor: UIColor,
        borderColor: UIColor,
        borderWidth: CGFloat,
        cornerRadius: CGFloat,
        textColor: UIColor,
        font: UIFont
    )
}
#endif

// MARK: - 监控协议

#if canImport(UIKit)

/// 性能监控抽象协议
/// 业务层面向此协议编程，底层实现可替换
@MainActor
public protocol PerformanceMonitoring: AnyObject {
    /// 性能数据回调
    var onReport: (@MainActor @Sendable (PerformanceReport) -> Void)? { get set }

    /// 启动监控并显示悬浮窗
    func start(options: PerformanceDisplayOptions, style: PerformanceViewStyle)

    /// 暂停监控
    func pause()

    /// 显示悬浮窗
    func show()

    /// 隐藏悬浮窗
    func hide()

    /// 更新显示选项
    func updateOptions(_ options: PerformanceDisplayOptions)

    /// 更新显示样式
    func updateStyle(_ style: PerformanceViewStyle)
}

/// 提供默认参数
extension PerformanceMonitoring {
    public func start(
        options: PerformanceDisplayOptions = .default,
        style: PerformanceViewStyle = .dark
    ) {
        start(options: options, style: style)
    }
}

#endif
