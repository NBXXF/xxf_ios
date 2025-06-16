//
//  Environment.swift
//  xxf_ios
//  环境相关
//  Created by xxf on 6/11.
//

public enum Environment {
    public static let isDebug: Bool = {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }()
}
