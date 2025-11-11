//
//  PlatformImageView.swift
//  xxf_ios
//  图片跨平台抽象别名
//  Created by xxf on 8/19.
//

import Foundation
#if canImport(UIKit)
    import UIKit

    public typealias PlatformImageView = UIImageView
    public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
    import AppKit

    public typealias PlatformImageView = NSImageView
    public typealias PlatformImage = NSImage
#endif
