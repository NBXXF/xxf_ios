//
//  HapticFeedback.swift
//  xxf_ios
//
//  Created by xxf
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

/// 触觉反馈封装（纯静态命名空间）
///
/// ## 特性
/// - 支持 Impact / Selection / Notification 三大类原语
/// - 自动 prepare，降低后续触发延迟
/// - 支持强度控制（intensity）
/// - 支持全局开关（isEnabled）
/// - 业务场景语义方法见 `HapticFeedback+Scene.swift`
///
/// ## 使用示例
/// ```swift
/// HapticFeedback.impact(.light)
/// HapticFeedback.impact(.medium, intensity: 0.5)
/// HapticFeedback.selection()
/// HapticFeedback.notify(.success)
///
/// // 业务场景
/// HapticFeedback.tap()
/// HapticFeedback.like()
///
/// // 全局关闭
/// HapticFeedback.isEnabled = false
/// ```
public enum HapticFeedback {

    // MARK: - 全局开关

    /// 全局开关，默认 true。关闭后所有反馈方法直接 return。
    public nonisolated(unsafe) static var isEnabled: Bool = true

    // MARK: - 类型定义

    /// 冲击反馈强度
    public enum ImpactStyle {
        /// 轻微（默认点击感）
        case light
        /// 中等（普通交互反馈）
        case medium
        /// 强烈（重要操作反馈）
        case heavy
        /// 柔和（如弹簧回弹）
        case soft
        /// 刚性（如切换开关）
        case rigid

        fileprivate var uiStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: return .light
            case .medium: return .medium
            case .heavy: return .heavy
            case .soft: return .soft
            case .rigid: return .rigid
            }
        }
    }

    /// 通知反馈类型
    public enum NotificationType {
        case success
        case warning
        case error

        fileprivate var uiType: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
            case .success: return .success
            case .warning: return .warning
            case .error: return .error
            }
        }
    }

    // MARK: - 内部生成器（按需缓存）

    private nonisolated(unsafe) static var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle.RawValue: UIImpactFeedbackGenerator] = [:]
    private nonisolated(unsafe) static let selectionGenerator = MainActor.assumeIsolated { UISelectionFeedbackGenerator() }
    private nonisolated(unsafe) static let notificationGenerator = MainActor.assumeIsolated { UINotificationFeedbackGenerator() }

    private static func impactGenerator(for style: ImpactStyle) -> UIImpactFeedbackGenerator {
        let key = style.uiStyle.rawValue
        if let g = impactGenerators[key] { return g }
        let g = UIImpactFeedbackGenerator(style: style.uiStyle)
        impactGenerators[key] = g
        return g
    }

    // MARK: - Impact

    /// 触发冲击反馈
    /// - Parameters:
    ///   - style: 反馈强度，默认 .light
    ///   - intensity: 强度 0.0 - 1.0，nil 表示系统默认
    public static func impact(_ style: ImpactStyle = .light, intensity: CGFloat? = nil) {
        guard isEnabled else { return }
        let generator = impactGenerator(for: style)
        if let intensity = intensity {
            generator.impactOccurred(intensity: max(0, min(1, intensity)))
        } else {
            generator.impactOccurred()
        }
        generator.prepare()
    }

    /// 预备冲击反馈（降低后续触发延迟）
    public static func prepareImpact(_ style: ImpactStyle = .light) {
        guard isEnabled else { return }
        impactGenerator(for: style).prepare()
    }

    // MARK: - Selection

    /// 触发选择变化反馈（适用于 Picker、Segment、Slider 等）
    public static func selection() {
        guard isEnabled else { return }
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    /// 预备选择反馈
    public static func prepareSelection() {
        guard isEnabled else { return }
        selectionGenerator.prepare()
    }

    // MARK: - Notification

    /// 触发通知反馈
    public static func notify(_ type: NotificationType) {
        guard isEnabled else { return }
        notificationGenerator.notificationOccurred(type.uiType)
        notificationGenerator.prepare()
    }

    /// 预备通知反馈
    public static func prepareNotification() {
        guard isEnabled else { return }
        notificationGenerator.prepare()
    }

}

#endif
