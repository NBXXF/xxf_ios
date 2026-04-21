#if os(iOS)
//
//  PlatformImageView+Task.swift
//  xxf_ios
//
//  Created by xxf on 8/19.
//

import Foundation
import Nuke
import ObjectiveC.runtime
import XXFImageLoader

// MARK: - PlatformImageView 扩展，用于保存 ImageTask

extension PlatformImageView {
    private static var kImageTaskKey: UInt8 = 0
    private static var kImageTaskIdKey: UInt8 = 1

    /// - Important: 存取方可能跨线程(主线程的 `load` / `cancel` 与 Nuke 完成回调
    ///   所在的用户 queue)。必须用 `.OBJC_ASSOCIATION_RETAIN`(原子版),
    ///   否则 NONATOMIC 的 retain/release 双线程交错会触发 double-release 崩溃。
    var nukeImageTask: ImageTask? {
        get {
            objc_getAssociatedObject(self, &Self.kImageTaskKey) as? ImageTask
        }
        set {
            objc_setAssociatedObject(self, &Self.kImageTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var nukeRequestId: UUID? {
        get { objc_getAssociatedObject(self, &Self.kImageTaskIdKey) as? UUID }
        set { objc_setAssociatedObject(self, &Self.kImageTaskIdKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
}
#endif
