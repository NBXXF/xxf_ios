//
//  HapticFeedback+Scene.swift
//  xxf_ios
//
//  业务场景化语义方法：基于三大类原语封装常见交互场景
//
//  Created by xxf
//

#if canImport(UIKit) && !os(watchOS)
import UIKit

public extension HapticFeedback {

    // MARK: - 通用交互

    /// 点击反馈（按钮/可点区域）
    static func tap() { impact(.light) }

    /// 长按反馈（长按菜单、拖拽开始）
    static func longPress() { impact(.medium) }

    /// 切换开关反馈（Switch、Toggle）
    static func toggle() { impact(.rigid) }

    /// 选择变化反馈（Picker、Segment）
    static func pick() { selection() }

    /// 吸附反馈（Slider 刻度吸附、磁吸对齐）
    static func snap() { selection() }

    /// 边界反馈（滚动到顶/底、到达范围极限）
    static func boundary() { impact(.rigid) }

    // MARK: - 社交 / 内容

    /// 点赞反馈
    static func like() { impact(.soft) }

    /// 收藏反馈
    static func favorite() { impact(.soft) }

    /// 关注成功反馈
    static func follow() { notify(.success) }

    // MARK: - 列表 / 刷新

    /// 下拉刷新触发反馈
    static func refresh() { impact(.medium) }

    /// 加载更多触发反馈
    static func loadMore() { impact(.light) }

    /// 侧滑操作露出反馈
    static func swipeAction() { impact(.medium) }

    /// 删除反馈（强调破坏性操作）
    static func delete() { impact(.heavy) }

    // MARK: - 导航 / 弹层

    /// 弹窗 / Modal 出现反馈
    static func modalPresent() { impact(.medium) }

    /// 抽屉展开 / 收起反馈
    static func drawer() { impact(.soft) }

    /// 翻页反馈
    static func pageChange() { impact(.light) }

    // MARK: - 表单 / 反馈

    /// 成功反馈（表单提交、支付成功、任务完成）
    static func success() { notify(.success) }

    /// 警告反馈（需要用户注意但非错误）
    static func warning() { notify(.warning) }

    /// 错误反馈（校验失败、操作失败）
    static func error() { notify(.error) }

    /// 复制成功反馈
    static func copied() { impact(.light) }
}

#endif
