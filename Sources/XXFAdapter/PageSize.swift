//
//  PageSize.swift
//  xxf_ios
//
//  Created by xxf on 2022/11/12.
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#elseif os(watchOS)
import WatchKit
#endif

public enum PageSize {
    /// 推荐分页条数
    public static var count: Int {
        #if os(iOS) || os(tvOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 20
        } else {
            // iPad 可单独设置
            return 40
        }
        #elseif os(macOS)
        return 60
        #elseif os(watchOS)
        return 10
        #else
        return 20
        #endif
    }
}
