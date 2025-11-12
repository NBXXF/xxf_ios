//
//  NSLabel.swift
//  xxf_ios
//  和uikit 对齐 UILabel
//  Created by xxf on 5/29.
//

import AppKit

public class NSLabel: NSTextField {
    public var text: String {
        get { stringValue }
        set { stringValue = newValue }
    }

    public var numberOfLines: Int = 1 {
        didSet {
            updateLineBreakAndMode()
        }
    }

    public var textAlignment: NSTextAlignment {
        get { alignment }
        set { alignment = newValue }
    }

    public override var textColor: NSColor? {
        didSet {
            // 不要赋值自己，避免死循环
        }
    }

    public override var font: NSFont? {
        didSet {
            // 同上
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

    public convenience init(text: String,
                            font: NSFont = NSFont.systemFont(ofSize: 14),
                            textColor: NSColor = .labelColor,
                            alignment: NSTextAlignment = .left,
                            numberOfLines: Int = 1)
    {
        self.init(frame: .zero)
        self.text = text
        self.font = font
        self.textColor = textColor
        textAlignment = alignment
        self.numberOfLines = numberOfLines
    }

    private func setup() {
        isEditable = false
        isSelectable = false
        drawsBackground = false
        isBezeled = false

        font = NSFont.systemFont(ofSize: 14)
        textColor = NSColor.labelColor

        updateLineBreakAndMode()
    }

    private func updateLineBreakAndMode() {
        if numberOfLines == 1 {
            usesSingleLineMode = true
            lineBreakMode = .byTruncatingTail
            maximumNumberOfLines = 1
        } else {
            usesSingleLineMode = false
            lineBreakMode = .byWordWrapping
            // 如果0不代表无限，改成大数字或者验证下
            maximumNumberOfLines = numberOfLines == 0 ? Int.max : numberOfLines
        }
        needsDisplay = true
    }

    public func setAttributedText(_ attributedText: NSAttributedString) {
        attributedStringValue = attributedText
    }
}
