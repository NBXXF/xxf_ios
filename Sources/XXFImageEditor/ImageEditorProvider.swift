#if canImport(UIKit)
import UIKit

/// 图片编辑器 Provider 协议
///
/// 实现此协议以提供具体的编辑/裁切 ViewController。
/// 外部代码只依赖此协议，无需关心底层实现库。
///
/// 切换底层库只需替换 `ImageEditor.shared.provider`，调用方代码无需修改。
@MainActor
public protocol ImageEditorProvider: AnyObject {

    /// 创建完整编辑器 ViewController（支持滤镜、调色、裁切等）
    /// - Parameters:
    ///   - image: 待编辑的原始图片
    ///   - configuration: 编辑器配置
    ///   - completion: 编辑完成或取消的回调（在主线程回调）
    /// - Returns: 可直接 present 的 ViewController
    func makeEditorViewController(
        image: UIImage,
        configuration: ImageEditorConfiguration,
        completion: @escaping @Sendable (Result<ImageEditorResult, ImageEditorError>) -> Void
    ) -> UIViewController

    /// 创建纯裁切 ViewController
    /// - Parameters:
    ///   - image: 待裁切的原始图片
    ///   - configuration: 裁切配置
    ///   - completion: 裁切完成或取消的回调（在主线程回调）
    /// - Returns: 可直接 present 的 ViewController
    func makeCropViewController(
        image: UIImage,
        configuration: ImageCropConfiguration,
        completion: @escaping @Sendable (Result<ImageEditorResult, ImageEditorError>) -> Void
    ) -> UIViewController
}
#endif
