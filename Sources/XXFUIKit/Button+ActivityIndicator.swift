#if canImport(UIKit)
import UIKit

@available(iOS 15.0, *)
public extension UIButton {
    /// 控制按钮是否显示 loading 指示器。
    ///
    /// 内部包装 `button.configuration?.showsActivityIndicator`。
    ///
    /// 若按钮未设置 `configuration`，setter 会自动初始化为 `.plain()`。
    /// 可用的预设样式：
    /// - `.plain()`      无背景无边框，文字用 tint 色，类似旧版 `.system`
    /// - `.borderless()` 与 `.plain()` 视觉几乎一致，语义上表示无边框
    /// - `.filled()`     有填充背景色（默认 tint 色），文字白色
    var showsActivityIndicator: Bool {
        get { configuration?.showsActivityIndicator ?? false }
        set {
            if configuration == nil {
                configuration = .plain()
            }
            configuration?.showsActivityIndicator = newValue
        }
    }
}

#elseif canImport(AppKit)
import AppKit

private enum AssociatedKeys {
    static var progressIndicator = "progressIndicator"
}

public extension NSButton {
    /// 控制按钮是否显示 loading 指示器。
    ///
    /// AppKit 的 `NSButton` 没有原生 indicator 属性，
    /// 内部通过在按钮中心叠加 `NSProgressIndicator` 子视图模拟实现。
    var showsActivityIndicator: Bool {
        get { progressIndicator?.isHidden == false }
        set {
            if newValue {
                let indicator = existingOrNewIndicator()
                indicator.isHidden = false
                indicator.startAnimation(nil)
            } else {
                progressIndicator?.isHidden = true
                progressIndicator?.stopAnimation(nil)
            }
        }
    }

    private var progressIndicator: NSProgressIndicator? {
        objc_getAssociatedObject(self, &AssociatedKeys.progressIndicator) as? NSProgressIndicator
    }

    private func existingOrNewIndicator() -> NSProgressIndicator {
        if let existing = progressIndicator { return existing }
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.controlSize = .small
        indicator.isIndeterminate = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        objc_setAssociatedObject(self, &AssociatedKeys.progressIndicator, indicator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return indicator
    }
}
#endif
