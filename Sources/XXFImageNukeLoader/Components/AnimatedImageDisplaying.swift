//
//  AnimatedImageDisplaying.swift
//  xxf_ios
//  动图 View 协议,解耦 ImageLoader 与具体播放实现
//  Created by xxf
//

#if os(iOS)
import UIKit

/// 动图 View 接入协议。
///
/// 加载端(如 `ImageNukeLoaderAdapter`)在下载/解码完成后,把结果通过本协议
/// 下发给实现方。实现方可按 `animatedImage` / `data` 自行决定播放或静态展示。
///
/// - Important:
///   `animatedImage` 由加载端在后台线程预先构造好(例如在 Nuke 的
///   `imageDecodingQueue` 上 `SDAnimatedImage(data:)`),主线程只负责
///   赋值,不再做重解码,避免列表滚动掉帧。
@MainActor
public protocol AnimatedImageDisplaying: AnyObject {
    /// - parameters:
    ///   - image: 静态首帧 / 静态图 `UIImage`。静态场景(JPEG/PNG 等)只会传这个。
    ///   - data: 原始字节。动图格式(GIF / WebP / HEIC)时非空;实现方可据此自建
    ///     动图对象(在 `animatedImage` 为空时的兜底)。
    ///   - animatedImage: 加载端后台预构造的动图 `UIImage`(如 `SDAnimatedImage`)。
    ///     非空时实现方应优先使用,避免主线程重复解码。
    func displayImage(_ image: UIImage?, data: Data?, animatedImage: UIImage?)
}
#endif
