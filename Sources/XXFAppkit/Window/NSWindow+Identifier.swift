//
//  NSWindow+Identifier.swift
//  xxf_ios
//  maocs 开发,页面状态记录不能单例,最好的方式就是跟window进行关联对象存储
//  Created by xxf on 7/17.
//

import AppKit

public extension NSWindow {
    /// 如果当前 identifier 为 nil，则自动生成一个 UUID 赋值并返回
    var identifierIfAbsent: NSUserInterfaceItemIdentifier {
        if let id = identifier {
            return id
        } else {
            let newID = NSUserInterfaceItemIdentifier(UUID().uuidString)
            identifier = newID
            return newID
        }
    }

    /// 只有当当前 identifier 为 nil 时，才设置传入的 identifier
    func setIdentifierIfAbsent(identifier: NSUserInterfaceItemIdentifier) {
        if self.identifier == nil {
            self.identifier = identifier
        }
    }

    /// 只有当当前 identifier 为 nil 时，才设置传入的字符串作为 identifier
    func setIdentifierIfAbsent(identifierString: String) {
        if identifier == nil {
            identifier = NSUserInterfaceItemIdentifier(identifierString)
        }
    }
}
