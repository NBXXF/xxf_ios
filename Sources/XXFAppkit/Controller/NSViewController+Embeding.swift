//
//  NSViewController+Embeding.swift
//  xxf_ios
//  vc 嵌套工具拓展
//  Created by xxf on 7/26.
//

import AppKit

public extension NSViewController {
    /// 添加子控制器到指定容器视图，默认全边界填充
    /// - Parameters:
    ///   - child: 子控制器
    ///   - containerView: 承载子控制器视图的容器视图
    /// - Returns: 是否成功添加
    @discardableResult
    func addChildViewController(_ child: NSViewController,
                                in containerView: NSView,
                                constraints: [NSLayoutConstraint]?) -> Bool
    {
        if children.contains(child) {
            return false // 已经是子控制器，忽略
        }

        addChild(child)

        // 视图生命周期回调（根据需要取消注释）
        // child.viewWillAppear()

        containerView.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        if let constraints = constraints {
            NSLayoutConstraint.activate(constraints)
        } else {
            NSLayoutConstraint.activate([
                child.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                child.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                child.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                child.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        }

        // macOS NSViewController 没有 didMove(toParent:)
        // child.didMove(toParent: self)

        // 视图生命周期回调（根据需要取消注释）
        // child.viewDidAppear()

        return true
    }

    /// 替换指定容器中的子控制器，将 oldChild 替换为 newChild
    /// - Parameters:
    ///   - replacing: 要被替换的子控制器（可选，nil 表示直接添加 newChild）
    ///   - newChild: 新的子控制器
    ///   - containerView: 承载子控制器视图的容器视图
    ///   - constraints: 子视图约束数组，已经是激活状态
    func replaceChildViewController(_ newChild: NSViewController,
                                    in containerView: NSView,
                                    constraints: [NSLayoutConstraint]? = nil,
                                    replacing oldChild: NSViewController? = nil)
    {
        // 避免重复添加
        guard !children.contains(newChild) else { return }

        addChild(newChild)
        containerView.addSubview(newChild.view)
        newChild.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(constraints ?? [
            newChild.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newChild.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newChild.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            newChild.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        if let old = oldChild, children.contains(old) {
            // 只移除指定 oldChild
            old.view.removeFromSuperview()
            old.removeFromParent()
        } else {
            // 没传 oldChild，清空 containerView 的其他 view（不清 children）
            for subview in containerView.subviews where subview !== newChild.view {
                subview.removeFromSuperview()
            }
        }
    }

    /// 从父控制器移除子控制器
    /// - Parameter child: 要移除的子控制器
    func removeChildViewController(_ child: NSViewController) {
        guard children.contains(child) else { return }

        // child.viewWillDisappear()

        // macOS NSViewController 没有 willMove(toParent: nil)
        // child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()

        // child.viewDidDisappear()
    }

    /// 从指定容器中移除子控制器及其视图（更安全）
    func removeChildViewController(_ child: NSViewController, in containerView: NSView) {
        guard children.contains(child) else { return }

        if child.view.superview === containerView {
            child.view.removeFromSuperview()
        }
        child.removeFromParent()
    }
}
