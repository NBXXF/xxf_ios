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

    var nukeImageTask: ImageTask? {
        get {
            objc_getAssociatedObject(self, &Self.kImageTaskKey) as? ImageTask
        }
        set {
            objc_setAssociatedObject(self, &Self.kImageTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var nukeRequestId: UUID? {
        get { objc_getAssociatedObject(self, &Self.kImageTaskIdKey) as? UUID }
        set { objc_setAssociatedObject(self, &Self.kImageTaskIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
