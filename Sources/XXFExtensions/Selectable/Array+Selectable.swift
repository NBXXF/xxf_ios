//
//  Selectable.swift
//  xxf_ios
//  选中控制
//  Created by xxf on 7/7.
//
public extension Array where Element: Selectable {
    /// 切换某一项的选择状态（根据选择模式决定逻辑）
    /// - Parameters:
    ///   - index: 目标项索引
    ///   - mode: 单选或多选
    mutating func toggleSelection(at index: Int, mode: SelectionMode = .multiple) {
        guard indices.contains(index) else { return }
        var item = self[index]
        guard !item.isDisabled else { return }

        switch mode {
        case .single:
            // 单选：取消其他选中，选中当前
            for (i, var obj) in enumerated() {
                guard !obj.isDisabled else { continue }
                obj.isSelected = (i == index)
            }
        case .multiple:
            // 多选：切换当前项
            item.toggleSelection()
        }
    }

    /// 全选（多选模式下有效）
    mutating func selectAll(mode: SelectionMode = .multiple) {
        guard mode == .multiple else { return }
        for var item in self where !item.isDisabled {
            item.isSelected = true
        }
    }

    /// 清除所有选择（适用于单选和多选）
    mutating func deselectAll() {
        for var item in self {
            item.isSelected = false
        }
    }

    /// 获取已选项
    var selectedItems: [Element] {
        filter { $0.isSelected }
    }
}
