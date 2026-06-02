//
//  XXFCustomNavigationBar+BarButtonItem.swift
//  xxf_ios
//
//  Created by xxf on 5/21.
//

#if canImport(UIKit)
import UIKit

/// 包装 `UIBarButtonItem.customView` 的容器。
///
/// stack view 需要稳定的 Auto Layout 尺寸；同时外部取锚点时仍应拿到原始 custom view。
final class XXFCustomNavigationContentWrapper: UIView {
    /// 被包装的原始 custom view。
    weak var contentView: UIView?
}

extension XXFCustomNavigationBar {

    // MARK: Bar Button Item Rendering

    /// 清空 stack view 中当前渲染出的按钮视图。
    func clearArrangedSubviews(in stackView: UIStackView) {
        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    /// 将一个 `UIBarButtonItem` 转成自绘导航栏可以展示的 view。
    ///
    /// 优先使用 `customView`，其次渲染 image/title/action/menu；没有可见内容但有宽度时按 spacer 处理。
    func viewForBarButtonItem(_ item: UIBarButtonItem) -> UIView? {
        if let customView = item.customView {
            customView.isUserInteractionEnabled = item.isEnabled
            return wrapCustomContentView(customView, minimumWidth: max(contentHeight, item.width))
        }

        let action = item.primaryAction
        let image = item.image ?? action?.image
        let title = item.title?.isEmpty == false ? item.title : (action?.title.isEmpty == false ? action?.title : nil)
        let menu = item.menu
        let hasAction = action != nil || item.target != nil || item.action != nil

        guard image != nil || title != nil || menu != nil || hasAction else {
            guard item.width > 0 else { return nil }
            let spacer = UIView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            spacer.widthAnchor.constraint(equalToConstant: item.width).isActive = true
            spacer.heightAnchor.constraint(equalToConstant: contentHeight).isActive = true
            return spacer
        }

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = item.isEnabled
        button.tintColor = item.tintColor ?? tintColor
        button.accessibilityLabel = item.accessibilityLabel
        button.accessibilityHint = item.accessibilityHint
        button.accessibilityIdentifier = item.accessibilityIdentifier

        if let image {
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        } else if title == nil {
            button.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        }
        if let title {
            applyTitle(title, to: button, from: item)
        }
        if let action {
            button.addAction(action, for: .touchUpInside)
        } else if let selector = item.action {
            button.addTarget(item.target, action: selector, for: .touchUpInside)
        }
        if let menu {
            button.menu = menu
            button.showsMenuAsPrimaryAction = action == nil && item.action == nil
        }

        let container = UIView()
        container.addSubview(button)

        let minimumWidth = max(contentHeight, item.width)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: minimumWidth + 16),
            container.heightAnchor.constraint(equalToConstant: contentHeight)
        ])
        return container
    }

    /// 为自绘 `UIButton` 应用 `UIBarButtonItem` 的标题和各状态标题样式。
    private func applyTitle(_ title: String, to button: UIButton, from item: UIBarButtonItem) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(button.tintColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)

        [UIControl.State.normal, .highlighted, .disabled].forEach { state in
            applyTitleAttributes(for: state, title: title, to: button, from: item)
        }
    }

    /// 将 `titleTextAttributes(for:)` 映射到 `UIButton` 对应状态的 attributed title。
    ///
    /// 当前兼容 `.normal`、`.highlighted`、`.disabled` 三种常用状态。
    private func applyTitleAttributes(
        for state: UIControl.State,
        title: String,
        to button: UIButton,
        from item: UIBarButtonItem
    ) {
        guard var attributes = item.titleTextAttributes(for: state), !attributes.isEmpty else { return }

        if attributes[.font] == nil, let font = button.titleLabel?.font {
            attributes[.font] = font
        }
        if attributes[.foregroundColor] == nil {
            attributes[.foregroundColor] = button.titleColor(for: state)
                ?? button.titleColor(for: .normal)
                ?? button.tintColor
        }

        button.setAttributedTitle(NSAttributedString(string: title, attributes: attributes), for: state)

        if state == .normal, let font = attributes[.font] as? UIFont {
            button.titleLabel?.font = font
        }
        if let color = attributes[.foregroundColor] as? UIColor {
            button.setTitleColor(color, for: state)
        }
    }

    /// 包装 custom view，给 stack view 提供稳定尺寸，同时保留原始 view 作为锚点。
    private func wrapCustomContentView(_ customView: UIView, minimumWidth: CGFloat) -> UIView {
        let wrapper = XXFCustomNavigationContentWrapper()
        wrapper.contentView = customView
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        customView.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(customView)

        NSLayoutConstraint.activate([
            customView.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            customView.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
            wrapper.heightAnchor.constraint(equalToConstant: contentHeight)
        ] + customContentSizeConstraints(for: customView, minimumWidth: minimumWidth))

        return wrapper
    }

    /// 为 `titleView` / `customView` 推导尺寸约束。
    ///
    /// 优先使用外部已有 Auto Layout / intrinsic size；frame-only view 则使用当前 frame 作为兜底。
    func customContentSizeConstraints(for customView: UIView, minimumWidth: CGFloat) -> [NSLayoutConstraint] {
        let preferredSize = Self.preferredSize(for: customView)
        let width = max(minimumWidth, preferredSize.width)
        let fallbackHeight = preferredSize.height > 0 ? min(preferredSize.height, contentHeight) : contentHeight

        var constraints: [NSLayoutConstraint] = []
        if width > 0 {
            constraints.append(customView.widthAnchor.constraint(greaterThanOrEqualToConstant: width))
        }

        let maxHeight = customView.heightAnchor.constraint(lessThanOrEqualToConstant: contentHeight)
        maxHeight.priority = .defaultHigh
        constraints.append(maxHeight)

        if !Self.hasUsableIntrinsicHeight(customView), !Self.hasExplicitHeightConstraint(customView) {
            constraints.append(customView.heightAnchor.constraint(equalToConstant: fallbackHeight))
        }
        return constraints
    }

    /// 从 bounds、frame、intrinsic size、compressed fitting size 中选择一个可用尺寸。
    private static func preferredSize(for view: UIView) -> CGSize {
        let intrinsicSize = view.intrinsicContentSize
        let fittingSize = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        let width = [view.bounds.width, view.frame.width, intrinsicSize.width, fittingSize.width]
            .first { $0 > 0 && $0 < CGFloat.greatestFiniteMagnitude } ?? 0
        let height = [view.bounds.height, view.frame.height, intrinsicSize.height, fittingSize.height]
            .first { $0 > 0 && $0 < CGFloat.greatestFiniteMagnitude } ?? 0
        return CGSize(width: width, height: height)
    }

    /// 判断 view 是否提供了可用 intrinsic 高度。
    private static func hasUsableIntrinsicHeight(_ view: UIView) -> Bool {
        view.intrinsicContentSize.height > 0
    }

    /// 判断 view 自身是否已经声明了高度约束。
    private static func hasExplicitHeightConstraint(_ view: UIView) -> Bool {
        view.constraints.contains { constraint in
            let firstMatches = (constraint.firstItem as AnyObject?) === view
                && constraint.firstAttribute == .height
            let secondMatches = (constraint.secondItem as AnyObject?) === view
                && constraint.secondAttribute == .height
            return firstMatches || secondMatches
        }
    }
}
#endif
