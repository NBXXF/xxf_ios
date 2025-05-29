//
//  NSTLabel.swift
//  xxf_ios
//  和uikit 对齐 UILabel
//  Created by xxf on 2025/5/29.
//

import AppKit

class NSLabel: NSTextField {
    /// 类似 UILabel 的 text 属性，方便赋值读取文本
    var text: String {
        get { stringValue }
        set { stringValue = newValue }
    }

    /// 控制显示的行数，默认1，0表示无限行
    var numberOfLines: Int = 1 {
        didSet {
            updateLineBreakAndMode()
        }
    }

    /// 文本对齐，默认左对齐，映射 NSTextAlignment
    var textAlignment: NSTextAlignment = .left {
        didSet {
            alignment = textAlignment
        }
    }

    /// 文本颜色，默认系统标签颜色
    override var textColor: NSColor? {
        didSet {
            textColor = textColor
        }
    }

    /// 字体，默认系统字体14号
    override var font: NSFont? {
        didSet {
            font = font
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isEditable = false
        isSelectable = false
        drawsBackground = false
        isBezeled = false

        // 默认单行显示，超出尾部显示省略号
        updateLineBreakAndMode()

        // 默认字体和颜色
        font = NSFont.systemFont(ofSize: 14)
        textColor = NSColor.labelColor

        // 默认左对齐
        alignment = .left
    }

    private func updateLineBreakAndMode() {
        if numberOfLines == 1 {
            usesSingleLineMode = true
            lineBreakMode = .byTruncatingTail
            maximumNumberOfLines = 1
        } else {
            usesSingleLineMode = false
            lineBreakMode = .byWordWrapping
            maximumNumberOfLines = numberOfLines == 0 ? 0 : numberOfLines
        }
        needsDisplay = true
    }

    /// 方便设置富文本
    func setAttributedText(_ attributedText: NSAttributedString) {
        attributedStringValue = attributedText
    }
}
