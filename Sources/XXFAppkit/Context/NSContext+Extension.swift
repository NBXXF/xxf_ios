//
//  NSContext+Extension.swift
//  xxf_ios
//
//  Created by xxf on 7/19.
//

public extension NSContext {
    /// 判断 是否已附加到某个 NSWindow
    var isWindowAttached: Bool {
        return attachedWindow != nil
    }
}
