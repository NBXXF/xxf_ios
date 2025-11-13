//
//  ProgressHudUtils.swift
//  xxf_ios
//
//  Created by xxf on 5/27.
//

public enum ProgressHudUtils {
#if os(iOS)
    public nonisolated(unsafe) static var progressHudHandler: ProgressHudHandler = DefaultProgressHudHandler()
#else
    public nonisolated(unsafe) static var progressHudHandler: ProgressHudHandler = DefaultProgressHudHandler()
#endif
}
