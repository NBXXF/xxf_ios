#if canImport(UIKit)
import UIKit
@preconcurrency import GDPerformanceView_Swift

/// GDPerformanceView-Swift 实现
/// 业务层不应直接使用此类，请通过 PerformanceMonitoring 协议访问
@MainActor
public final class GDPerformanceMonitorView: NSObject, PerformanceMonitoring {

    public static let shared = GDPerformanceMonitorView()

    public var onReport: (@MainActor @Sendable (PerformanceReport) -> Void)?

    private let monitor: PerformanceMonitor

    private override init() {
        monitor = PerformanceMonitor.shared()
        super.init()
        monitor.delegate = self
    }

    // MARK: - PerformanceMonitoring

    public func start(options: PerformanceDisplayOptions, style: PerformanceViewStyle) {
        applyOptions(options)
        applyStyle(style)
        monitor.start()
    }

    public func pause() {
        monitor.pause()
    }

    public func show() {
        monitor.show()
    }

    public func hide() {
        monitor.hide()
    }

    public func updateOptions(_ options: PerformanceDisplayOptions) {
        applyOptions(options)
    }

    public func updateStyle(_ style: PerformanceViewStyle) {
        applyStyle(style)
    }

    // MARK: - Private

    private func applyOptions(_ options: PerformanceDisplayOptions) {
        var gdOptions: PerformanceMonitor.DisplayOptions = []
        if options.contains(.performance) { gdOptions.insert(.performance) }
        if options.contains(.memory) { gdOptions.insert(.memory) }
        if options.contains(.application) { gdOptions.insert(.application) }
        if options.contains(.device) { gdOptions.insert(.device) }
        if options.contains(.system) { gdOptions.insert(.system) }
        monitor.performanceViewConfigurator.options = gdOptions
    }

    private func applyStyle(_ style: PerformanceViewStyle) {
        switch style {
        case .dark:
            monitor.performanceViewConfigurator.style = .dark
        case .light:
            monitor.performanceViewConfigurator.style = .light
        case .custom(let bg, let border, let borderWidth, let cornerRadius, let textColor, let font):
            monitor.performanceViewConfigurator.style = .custom(
                backgroundColor: bg,
                borderColor: border,
                borderWidth: borderWidth,
                cornerRadius: cornerRadius,
                textColor: textColor,
                font: font
            )
        }
    }
}

// MARK: - PerformanceMonitorDelegate

extension GDPerformanceMonitorView: PerformanceMonitorDelegate {
    nonisolated public func performanceMonitor(didReport performanceReport: GDPerformanceView_Swift.PerformanceReport) {
        let report = PerformanceReport(
            cpuUsage: performanceReport.cpuUsage,
            fps: performanceReport.fps,
            memoryUsed: performanceReport.memoryUsage.used,
            memoryTotal: performanceReport.memoryUsage.total
        )
        MainActor.assumeIsolated {
            onReport?(report)
        }
    }
}

#endif
