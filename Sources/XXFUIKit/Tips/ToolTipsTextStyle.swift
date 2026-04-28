//
//  ToolTipsTextStyle.swift
//  AppUIKit
//
//  ToolTips 默认文本样式（SPM 统一出口）
//

#if canImport(UIKit)
import UIKit

/// ToolTips 文本样式规范。
/// 规则：默认 12 / black / regular。
public enum ToolTipsTextStyle {
    public static let defaultFont: UIFont = UIFont(name: "Inter-Regular", size: 12) ?? .systemFont(ofSize: 12, weight: .regular)
    public static let defaultTextColor: UIColor = .black
}
#elseif canImport(AppKit)
import AppKit

/// ToolTips 文本样式规范（macOS 兼容定义）。
public enum ToolTipsTextStyle {
    nonisolated(unsafe) public static let defaultFont: NSFont = .systemFont(ofSize: 12, weight: .regular)
    public static let defaultTextColor: NSColor = .black
}
#endif
