#if os(iOS)
//
//  AnimatedImageView.swift
//  xxf_ios
//  通用动图 ImageView,对外 API 与 UIImageView 一致
//  支持 GIF / APNG / 动图 WebP / 动图 HEIC
//  Created by xxf
//
import Nuke
import SDWebImage
import UIKit

/// 通用动图 ImageView。
///
/// 使用方式与 `UIImageView` 完全一致,通过 `Imageloader.load().into(_:)`
/// 或 `loadRemoteImage(_:)` 加载:
/// - 动图 (GIF / APNG / 动图 WebP / 动图 HEIC) 自动识别并播放
/// - 静态图 (JPEG / PNG / 静态 WebP / 静态 HEIC 等) 按原生 UIImageView 行为显示
///
/// 注意:cell 复用场景需在 `prepareForReuse` 调用本类的 `prepareForReuse()`。
public class AnimatedImageView: SDAnimatedImageView {
    // MARK: - Nuke Integration

    /// 覆盖 Nuke 默认 hook,基于响应携带的原始 data 构造 `SDAnimatedImage`,
    /// 交由 `SDAnimatedImageView` 播放;无 data 或非动图则回退到原生静态路径。
    ///
    /// - Important: 需要 `ImageNukeLoaderAdapter` 为 WebP / HEIC 等动图格式
    ///   在 `ImageContainer.data` 中保留原始字节(Nuke 默认解码器仅对 GIF 保留)。
    override open func nuke_display(image: UIImage?, data: Data?) {
        if let data, let animated = SDAnimatedImage(data: data) {
            self.image = animated
            startAnimating()
        } else {
            stopAnimating()
            super.nuke_display(image: image, data: data)
        }
    }

    // MARK: - Reuse

    /// Cell 复用时调用,停止动画 + 清空内容
    open func prepareForReuse() {
        stopAnimating()
        image = nil
    }
}
#endif
