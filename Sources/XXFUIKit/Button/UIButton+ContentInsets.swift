//
//  UIButton+ContentInsets.swift
//  nexus
//
//  iOS 15+ 的 `contentEdgeInsets` 替代,内部走 UIButton.Configuration.contentInsets。
//  带 legacy 状态自动迁移(font / color / alignment),避免切到 Configuration 路径
//  后 UIKit 自动迁移不完整导致的样式回归。
//
#if canImport(UIKit)
import UIKit

public extension UIButton {
    /// `contentEdgeInsets` 的替代(iOS 15+ 已过时),内部走 `Configuration.contentInsets`。
    ///
    /// 用法和 `contentEdgeInsets` 几乎一致:
    /// ```swift
    /// button.contentInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
    /// ```
    ///
    /// ## 行为细节
    /// setter 首次赋值会把按钮切到 Configuration 渲染路径。为了避免 legacy 样式丢失,
    /// 会**显式迁移**下列属性进 Configuration(只在第一次建 config 时做,后续 setter 只改 insets):
    ///
    /// - `title(for: .normal)` + `titleLabel?.font` + `titleColor(for: .normal)`
    ///   → `config.attributedTitle`(AttributedString 承载 font/color)
    /// - `image(for: .normal)` → `config.image`
    /// - `contentHorizontalAlignment` → `config.titleAlignment`
    ///
    /// 不迁移的(仍走原位,不受影响):
    /// - `backgroundColor` → UIView 层属性,Configuration 路径下仍然生效
    /// - `layer.cornerRadius` → layer 属性,和 config 无关
    /// - `isEnabled` → UIControl 属性,正常
    ///
    /// ## 限制
    /// - 只迁移 `.normal` 状态。如果按钮通过 `setTitle(x, for: .highlighted)` 等多状态设样式,
    ///   切到 Configuration 后需要用 `configurationUpdateHandler` 在 callsite 实现。
    /// - Configuration 路径会给按钮自动加轻微按压态动画(scale+alpha),视觉微变不算 bug。
    /// - getter 只反映 Configuration 状态;未赋值过返回 `.zero`,不读取 legacy 避免自身触发告警。
    var contentInsets: UIEdgeInsets {
        get {
            guard let d = configuration?.contentInsets else { return .zero }
            return UIEdgeInsets(top: d.top, left: d.leading, bottom: d.bottom, right: d.trailing)
        }
        set {
            var config = self.configuration ?? makeMigratedConfig()
            config.contentInsets = NSDirectionalEdgeInsets(
                top: newValue.top,
                leading: newValue.left,
                bottom: newValue.bottom,
                trailing: newValue.right
            )
            self.configuration = config
        }
    }

    /// 从 legacy API 状态构造一份 Configuration,保真切换到新渲染路径。
    ///
    /// 构造完后 UIKit 仍会尝试自动迁移未覆盖的属性(如背景色),但我们这里显式处理
    /// UIKit 自动迁移不可靠的三项:title 的 font/color、image、水平对齐。
    private func makeMigratedConfig() -> UIButton.Configuration {
        var config = UIButton.Configuration.plain()

        // 标题 + 字体 + 颜色 → AttributedString
        // 只有 config.title(纯 String)会丢 font 和 color,必须走 attributedTitle。
        if let title = self.title(for: .normal), !title.isEmpty {
            var attr = AttributedString(title)
            if let font = self.titleLabel?.font {
                attr.font = font
            }
            if let color = self.titleColor(for: .normal) {
                attr.foregroundColor = color
            }
            config.attributedTitle = attr
        }

        // 图片(只迁 .normal 态;其他状态需要 callsite 手动处理)
        if let image = self.image(for: .normal) {
            config.image = image
        }

        // 水平对齐:Configuration 有自己的 titleAlignment,会覆盖
        // UIControl.contentHorizontalAlignment 的效果,需要同步。
        switch self.contentHorizontalAlignment {
        case .left, .leading:
            config.titleAlignment = .leading
        case .right, .trailing:
            config.titleAlignment = .trailing
        case .center:
            config.titleAlignment = .center
        case .fill:
            // .fill 在 Configuration 里没有直接对应,退回 .automatic 让系统决定
            config.titleAlignment = .automatic
        @unknown default:
            break
        }

        return config
    }
}
#endif
