//
//  Selectable.swift
//  xxf_ios
//  ui选择交互,可以结合数组封装的拓展 [Array+Selectable]
//  Created by xxf on 7/7.
//

import Foundation

/// 可选中模型协议
public protocol Selectable {
    /// 是否禁用选项
    var isDisabled: Bool { get set }

    /// 是否选中
    var isSelected: Bool { get set }
}

public extension Selectable {
    mutating func toggleSelection() {
        guard !isDisabled else { return } // 禁用时不切换
        isSelected.toggle()
    }
}
