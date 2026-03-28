//
//  PageSize.swift
//  xxf_ios
//
//  Created by xxf on 2022/11/12.
//


/// 分页条数常量
public enum PageSize {
    /// 推荐拉取条数
    public static var count: Int {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 20
        } else {
            // iPad 可以单独设置，如果需要
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
