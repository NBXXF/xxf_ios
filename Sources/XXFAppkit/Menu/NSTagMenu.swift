//
//  NSMenu+Extension.swift
//  xxf_ios
//  屏蔽没有tag的menu,系统一般是tag为0，但放行分隔符和 macOS 14+ 的 section header
//  Created by xxf on 7/18.
//
import AppKit

open class NSTagMenu: NSFilterMenu {
    public init(title: String = "") {
        super.init(title: title, filter: { item in
            if item.tag != 0 || item.isSeparatorItem {
                return true
            }
            if #available(macOS 14.0, *) {
                return item.isSectionHeader
            }
            return false
        })
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
