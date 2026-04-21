#if os(iOS)
//
//  AnimatedImageView.swift
//  xxf_ios
//  通用动图 ImageView,对外 API 与 UIImageView 一致
//  支持 GIF / APNG / 动图 WebP / 动图 HEIC
//  Created by xxf
//
import SDWebImage
import UIKit

/// 通用动图 ImageView。
///
/// 使用方式与 `UIImageView` 完全一致,通过 `Imageloader.load().into(_:)`
/// - 动图 (GIF / APNG / 动图 WebP / 动图 HEIC) 自动识别并播放
/// - 静态图 (JPEG / PNG / 静态 WebP / 静态 HEIC 等) 按原生 UIImageView 行为显示
///
/// 注意:cell 复用场景需在 `prepareForReuse` 调用本类的 `prepareForReuse()`。
public class AnimatedImageView: SDAnimatedImageView, AnimatedImageDisplaying {
    // MARK: - AnimatedImageDisplaying

    /// 适配器下发数据的三个可能形态:
    /// 1. `animatedImage` 非空:加载端已在后台构造好 SDAnimatedImage,直接赋值,**主线程零解码**(推荐路径)
    /// 2. `data` 非空:回退 —— 当前主线程现场 `SDAnimatedImage(data:)`(非推荐,留作兼容其他加载链)
    /// 3. 都空:静态图,走原生 UIImageView 行为
    public func displayImage(_ image: UIImage?, data: Data?, animatedImage: UIImage?) {
        if let animatedImage {
            self.image = animatedImage
            startAnimating()
            return
        }
        if let data, let animated = SDAnimatedImage(data: data) {
            self.image = animated
            startAnimating()
            return
        }
        stopAnimating()
        self.image = image
    }

    // MARK: - Reuse

    /// Cell 复用时调用,停止动画 + 清空内容
    open func prepareForReuse() {
        stopAnimating()
        image = nil
    }
}
#endif
