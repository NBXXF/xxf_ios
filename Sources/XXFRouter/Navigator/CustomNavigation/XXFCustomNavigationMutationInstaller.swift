//
//  XXFCustomNavigationMutationInstaller.swift
//  xxf_ios
//
//  Created by xxf on 5/21.
//

#if canImport(UIKit)
import ObjectiveC.runtime
import UIKit

// MARK: - Mutation Notification

extension Notification.Name {
    /// UIKit 导航相关 setter 被调用后的内部通知。
    ///
    /// object 为发生变化的 `UIViewController` / `UINavigationItem` / `UIBarButtonItem`。
    static let xxfCustomNavigationSourceDidChange = Notification.Name("xxf.customNavigation.sourceDidChange")
}

/// 安装 UIKit 导航字段 setter hook。
///
/// 目的不是改变 UIKit 行为，而是在外部延迟/异步修改 `title`、`navigationItem`、`UIBarButtonItem`
/// 后通知自绘导航栏重新读取 UIKit 状态。
enum XXFCustomNavigationMutationInstaller {
    /// 保护 hook 只安装一次。
    private static let lock = NSLock()

    /// 记录当前进程内是否已经完成 hook 安装。
    private static var isInstalled = false

    /// 安装所有需要监听的 UIKit setter hook。
    ///
    /// 该方法可重复调用；首次调用后会交换实现，后续直接返回。
    static func installIfNeeded() {
        lock.lock()
        defer { lock.unlock() }

        guard !isInstalled else { return }
        isInstalled = true

        swizzle(UIViewController.self,
                original: #selector(setter: UIViewController.title),
                replacement: #selector(UIViewController.xxf_customNavigation_setTitle(_:)))

        swizzle(UINavigationItem.self,
                original: #selector(setter: UINavigationItem.title),
                replacement: #selector(UINavigationItem.xxf_customNavigation_setTitle(_:)))
        swizzle(UINavigationItem.self,
                original: #selector(setter: UINavigationItem.titleView),
                replacement: #selector(UINavigationItem.xxf_customNavigation_setTitleView(_:)))
        swizzle(UINavigationItem.self,
                original: #selector(setter: UINavigationItem.leftBarButtonItem),
                replacement: #selector(UINavigationItem.xxf_customNavigation_setLeftBarButtonItem(_:)))
        swizzle(UINavigationItem.self,
                original: #selector(setter: UINavigationItem.leftBarButtonItems),
                replacement: #selector(UINavigationItem.xxf_customNavigation_setLeftBarButtonItems(_:)))
        swizzle(UINavigationItem.self,
                original: #selector(UINavigationItem.setLeftBarButtonItems(_:animated:)),
                replacement: #selector(UINavigationItem.xxf_customNavigation_setLeftBarButtonItems(_:animated:)))
        swizzle(UINavigationItem.self,
                original: #selector(setter: UINavigationItem.rightBarButtonItem),
                replacement: #selector(UINavigationItem.xxf_customNavigation_setRightBarButtonItem(_:)))
        swizzle(UINavigationItem.self,
                original: #selector(setter: UINavigationItem.rightBarButtonItems),
                replacement: #selector(UINavigationItem.xxf_customNavigation_setRightBarButtonItems(_:)))
        swizzle(UINavigationItem.self,
                original: #selector(UINavigationItem.setRightBarButtonItems(_:animated:)),
                replacement: #selector(UINavigationItem.xxf_customNavigation_setRightBarButtonItems(_:animated:)))
        swizzle(UINavigationItem.self,
                original: #selector(setter: UINavigationItem.hidesBackButton),
                replacement: #selector(UINavigationItem.xxf_customNavigation_setHidesBackButton(_:)))
        swizzle(UINavigationItem.self,
                original: #selector(UINavigationItem.setHidesBackButton(_:animated:)),
                replacement: #selector(UINavigationItem.xxf_customNavigation_setHidesBackButton(_:animated:)))
        swizzle(UINavigationItem.self,
                original: #selector(setter: UINavigationItem.leftItemsSupplementBackButton),
                replacement: #selector(UINavigationItem.xxf_customNavigation_setLeftItemsSupplementBackButton(_:)))

        swizzle(UIBarButtonItem.self,
                original: #selector(setter: UIBarButtonItem.title),
                replacement: #selector(UIBarButtonItem.xxf_customNavigation_setTitle(_:)))
        swizzle(UIBarButtonItem.self,
                original: #selector(setter: UIBarButtonItem.image),
                replacement: #selector(UIBarButtonItem.xxf_customNavigation_setImage(_:)))
        swizzle(UIBarButtonItem.self,
                original: #selector(setter: UIBarButtonItem.isEnabled),
                replacement: #selector(UIBarButtonItem.xxf_customNavigation_setEnabled(_:)))
        swizzle(UIBarButtonItem.self,
                original: #selector(setter: UIBarButtonItem.tintColor),
                replacement: #selector(UIBarButtonItem.xxf_customNavigation_setTintColor(_:)))
        swizzle(UIBarButtonItem.self,
                original: #selector(setter: UIBarButtonItem.customView),
                replacement: #selector(UIBarButtonItem.xxf_customNavigation_setCustomView(_:)))
        swizzle(UIBarButtonItem.self,
                original: #selector(setter: UIBarButtonItem.width),
                replacement: #selector(UIBarButtonItem.xxf_customNavigation_setWidth(_:)))
        swizzle(UIBarButtonItem.self,
                original: #selector(setter: UIBarButtonItem.menu),
                replacement: #selector(UIBarButtonItem.xxf_customNavigation_setMenu(_:)))
        swizzle(UIBarButtonItem.self,
                original: #selector(setter: UIBarButtonItem.target),
                replacement: #selector(UIBarButtonItem.xxf_customNavigation_setTarget(_:)))
        swizzle(UIBarButtonItem.self,
                original: #selector(setter: UIBarButtonItem.action),
                replacement: #selector(UIBarButtonItem.xxf_customNavigation_setAction(_:)))
        swizzle(UIBarButtonItem.self,
                original: #selector(setter: UIBarButtonItem.primaryAction),
                replacement: #selector(UIBarButtonItem.xxf_customNavigation_setPrimaryAction(_:)))
        swizzle(UIBarButtonItem.self,
                original: #selector(UIBarButtonItem.setTitleTextAttributes(_:for:)),
                replacement: #selector(UIBarButtonItem.xxf_customNavigation_setTitleTextAttributes(_:for:)))
    }

    /// 交换指定类上的两个实例方法实现。
    private static func swizzle(_ cls: AnyClass, original: Selector, replacement: Selector) {
        guard let originalMethod = class_getInstanceMethod(cls, original),
              let replacementMethod = class_getInstanceMethod(cls, replacement) else {
            return
        }
        method_exchangeImplementations(originalMethod, replacementMethod)
    }
}

private extension NSObject {
    /// 发送内部导航源变更通知。
    func xxf_postCustomNavigationSourceDidChange() {
        NotificationCenter.default.post(name: .xxfCustomNavigationSourceDidChange, object: self)
    }
}

private extension UIViewController {
    /// 监听 `UIViewController.title` 修改。
    @objc func xxf_customNavigation_setTitle(_ title: String?) {
        xxf_customNavigation_setTitle(title)
        xxf_postCustomNavigationSourceDidChange()
    }
}

private extension UINavigationItem {
    /// 监听 `navigationItem.title` 修改。
    @objc func xxf_customNavigation_setTitle(_ title: String?) {
        xxf_customNavigation_setTitle(title)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听 `navigationItem.titleView` 修改。
    @objc func xxf_customNavigation_setTitleView(_ titleView: UIView?) {
        xxf_customNavigation_setTitleView(titleView)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听单个左侧按钮修改。
    @objc func xxf_customNavigation_setLeftBarButtonItem(_ item: UIBarButtonItem?) {
        xxf_customNavigation_setLeftBarButtonItem(item)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听左侧按钮数组修改。
    @objc func xxf_customNavigation_setLeftBarButtonItems(_ items: [UIBarButtonItem]?) {
        xxf_customNavigation_setLeftBarButtonItems(items)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听带动画参数的左侧按钮数组修改。
    @objc func xxf_customNavigation_setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        xxf_customNavigation_setLeftBarButtonItems(items, animated: animated)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听单个右侧按钮修改。
    @objc func xxf_customNavigation_setRightBarButtonItem(_ item: UIBarButtonItem?) {
        xxf_customNavigation_setRightBarButtonItem(item)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听右侧按钮数组修改。
    @objc func xxf_customNavigation_setRightBarButtonItems(_ items: [UIBarButtonItem]?) {
        xxf_customNavigation_setRightBarButtonItems(items)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听带动画参数的右侧按钮数组修改。
    @objc func xxf_customNavigation_setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        xxf_customNavigation_setRightBarButtonItems(items, animated: animated)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听默认返回按钮隐藏状态修改。
    @objc func xxf_customNavigation_setHidesBackButton(_ hidesBackButton: Bool) {
        xxf_customNavigation_setHidesBackButton(hidesBackButton)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听带动画参数的默认返回按钮隐藏状态修改。
    @objc func xxf_customNavigation_setHidesBackButton(_ hidesBackButton: Bool, animated: Bool) {
        xxf_customNavigation_setHidesBackButton(hidesBackButton, animated: animated)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听左侧按钮是否补充默认返回按钮的语义修改。
    @objc func xxf_customNavigation_setLeftItemsSupplementBackButton(_ supplementBackButton: Bool) {
        xxf_customNavigation_setLeftItemsSupplementBackButton(supplementBackButton)
        xxf_postCustomNavigationSourceDidChange()
    }
}

private extension UIBarButtonItem {
    /// 监听 `UIBarButtonItem.title` 修改。
    @objc func xxf_customNavigation_setTitle(_ title: String?) {
        xxf_customNavigation_setTitle(title)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听 `UIBarButtonItem.image` 修改。
    @objc func xxf_customNavigation_setImage(_ image: UIImage?) {
        xxf_customNavigation_setImage(image)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听 `UIBarButtonItem.isEnabled` 修改。
    @objc func xxf_customNavigation_setEnabled(_ isEnabled: Bool) {
        xxf_customNavigation_setEnabled(isEnabled)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听 `UIBarButtonItem.tintColor` 修改。
    @objc func xxf_customNavigation_setTintColor(_ tintColor: UIColor?) {
        xxf_customNavigation_setTintColor(tintColor)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听 `UIBarButtonItem.customView` 修改。
    @objc func xxf_customNavigation_setCustomView(_ customView: UIView?) {
        xxf_customNavigation_setCustomView(customView)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听 `UIBarButtonItem.width` 修改。
    @objc func xxf_customNavigation_setWidth(_ width: CGFloat) {
        xxf_customNavigation_setWidth(width)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听 `UIBarButtonItem.menu` 修改。
    @objc func xxf_customNavigation_setMenu(_ menu: UIMenu?) {
        xxf_customNavigation_setMenu(menu)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听 `UIBarButtonItem.target` 修改。
    @objc func xxf_customNavigation_setTarget(_ target: AnyObject?) {
        xxf_customNavigation_setTarget(target)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听 `UIBarButtonItem.action` 修改。
    @objc func xxf_customNavigation_setAction(_ action: Selector?) {
        xxf_customNavigation_setAction(action)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听 `UIBarButtonItem.primaryAction` 修改。
    @objc func xxf_customNavigation_setPrimaryAction(_ primaryAction: UIAction?) {
        xxf_customNavigation_setPrimaryAction(primaryAction)
        xxf_postCustomNavigationSourceDidChange()
    }

    /// 监听 `UIBarButtonItem` 标题样式修改。
    @objc func xxf_customNavigation_setTitleTextAttributes(
        _ attributes: [NSAttributedString.Key: Any]?,
        for state: UIControl.State
    ) {
        xxf_customNavigation_setTitleTextAttributes(attributes, for: state)
        xxf_postCustomNavigationSourceDidChange()
    }
}
#endif
