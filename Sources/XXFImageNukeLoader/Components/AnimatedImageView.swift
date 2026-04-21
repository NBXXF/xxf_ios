//
//  AnimatedImageView.swift
//  xxf_ios
//  支持 GIF 的 UIImageView 替代品,对外 API 与 UIImageView 一致
//  Created by xxf
//
import Gifu
import Nuke
import UIKit
  
/// 支持 GIF 动图的 ImageView
///
/// 使用方式与 UIImageView 完全一致,通过 `Imageloader.load().into(_:)`
/// 或 `loadRemoteImage(_:)` 加载时:
/// - GIF 自动播放
/// - 静态图(JPEG/PNG/WebP)按原生 UIImageView 行为显示
///
/// 注意:cell 复用场景需在 `prepareForReuse` 调用本类的 `prepareForReuse()`
/// 或在取消加载时调用 `stopAnimatingGIF()`,避免旧 GIF 继续播放。
public class AnimatedImageView: GIFImageView {
    // MARK: - Nuke Integration

    /// 覆盖 Nuke 默认实现,拦截 GIF 数据走动画路径,其余走原生 UIImageView
    override open func nuke_display(image: UIImage?, data: Data?) {
        if let data, Self.isGIFData(data) {
            animate(withGIFData: data)
        } else {
            stopAnimatingGIF()
            super.nuke_display(image: image, data: data)
        }
    }
                                                                                                                                                                                                                                
    // MARK: - Reuse
  
    /// Cell 复用时调用,停止动画 + 清空内容
    open func prepareForReuse() {
        stopAnimatingGIF()
        image = nil
    }
                                                                                                                                                                                                                                
    // MARK: - Helpers
                                                                                                                                                                                                                                
    /// 检测 GIF 文件头("GIF87a" / "GIF89a",前 3 字节 0x47 0x49 0x46)
    private static func isGIFData(_ data: Data) -> Bool {
        guard data.count >= 3 else { return false }
        return data[0] == 0x47 && data[1] == 0x49 && data[2] == 0x46
    }
}
                                     
