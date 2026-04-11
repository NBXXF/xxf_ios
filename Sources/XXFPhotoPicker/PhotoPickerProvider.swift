#if canImport(UIKit)
import UIKit

/// 图片视频选择器 Provider 协议
///
/// 实现此协议以提供具体的选择器 ViewController。
/// 外部代码只依赖此协议，无需关心底层实现库。
///
/// 切换底层库只需替换 `PhotoPicker.shared.provider`，调用方代码无需修改。
@MainActor
public protocol PhotoPickerProvider: AnyObject {

    /// 创建图片视频选择器 ViewController
    /// - Parameters:
    ///   - configuration: 选择器配置
    ///   - completion: 选择完成或取消的回调（在主线程回调）
    /// - Returns: 可直接 present 的 ViewController
    func makePickerViewController(
        configuration: PhotoPickerConfiguration,
        completion: @escaping @Sendable (Result<[PhotoPickerResult], PhotoPickerError>) -> Void
    ) -> UIViewController

    /// 创建相机拍摄 ViewController
    /// - Parameters:
    ///   - configuration: 相机配置
    ///   - completion: 拍摄完成或取消的回调（在主线程回调）
    /// - Returns: 可直接 present 的 ViewController
    func makeCameraViewController(
        configuration: CameraConfiguration,
        completion: @escaping @Sendable (Result<PhotoPickerResult, PhotoPickerError>) -> Void
    ) -> UIViewController
}
#endif
