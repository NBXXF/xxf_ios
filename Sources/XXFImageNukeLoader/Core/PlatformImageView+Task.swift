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

// MARK: - 自动取消令牌
// UIImageView 释放时关联对象随之释放 → deinit 触发 → task.cancel()
// 无需任何 VC 手动管理并发槽
final class NukeTaskCancellationToken {
    private let task: ImageTask
    init(_ task: ImageTask) { self.task = task }
    deinit { task.cancel() }
}

// MARK: - PlatformImageView 扩展，用于保存取消令牌

extension PlatformImageView {
    private nonisolated(unsafe) static var kCancellationTokenKey: UInt8 = 0
    private nonisolated(unsafe) static var kImageTaskIdKey: UInt8 = 1

    /// 存取方可能跨线程，使用原子版 RETAIN 避免 double-release。
    /// 置 nil 时 deinit 触发，自动取消关联的 ImageTask。
    var nukeCancellationToken: NukeTaskCancellationToken? {
        get {
            objc_getAssociatedObject(self, &Self.kCancellationTokenKey) as? NukeTaskCancellationToken
        }
        set {
            objc_setAssociatedObject(self, &Self.kCancellationTokenKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    var nukeRequestId: UUID? {
        get { objc_getAssociatedObject(self, &Self.kImageTaskIdKey) as? UUID }
        set { objc_setAssociatedObject(self, &Self.kImageTaskIdKey, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
}
#endif
