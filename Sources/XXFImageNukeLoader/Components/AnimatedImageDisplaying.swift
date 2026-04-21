//
//  AnimatedImageDisplaying.swift
//  xxf_ios
//  动图 View 协议,解耦 ImageLoader 与具体播放实现
//  Created by xxf
//

#if os(iOS)
import UIKit

/// 由 ImageLoader 在加载完成后下发首帧 UIImage + 原始字节。
/// 实现方可按 `data` 的 magic bytes(GIF / 动画 WebP 等)自行切换动画或静态展示。
///
/// 替代此前直接 override Nuke `nuke_display(image:data:)` 的做法,
/// 不再依赖 NukeExtensions 的 `@objc` 协议。
@MainActor
public protocol AnimatedImageDisplaying: AnyObject {
    func displayImage(_ image: UIImage?, data: Data?)
}
#endif
