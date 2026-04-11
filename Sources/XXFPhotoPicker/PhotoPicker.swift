#if canImport(UIKit)
import UIKit

/// 图片视频选择器门面
///
/// 使用方式：
/// ```swift
/// // 初始化时注册 provider（只需一次，通常在 AppDelegate）
/// import XXFPhotoPickerZl
/// PhotoPicker.shared.provider = ZLPhotoPickerProvider()
///
/// // 使用（只需 import XXFPhotoPicker）
/// PhotoPicker.shared.presentPicker(from: self, configuration: .default) { result in
///     switch result {
///     case .success(let results): print(results)
///     case .failure(let error): print(error)
///     }
/// }
/// ```
@MainActor
public final class PhotoPicker {

    /// 全局共享实例
    public static let shared = PhotoPicker()

    /// 底层实现 Provider，替换此属性即可切换选择库，无需修改调用方代码
    public var provider: (any PhotoPickerProvider)?

    private init() {}

    // MARK: - Present Picker

    /// 弹出图片视频选择器
    /// - Parameters:
    ///   - viewController: 当前 ViewController
    ///   - configuration: 选择器配置，默认使用 `.default`
    ///   - animated: 是否动画弹出，默认 true
    ///   - completion: 选择结果回调
    public func presentPicker(
        from viewController: UIViewController,
        configuration: PhotoPickerConfiguration = .default,
        animated: Bool = true,
        completion: @escaping @Sendable (Result<[PhotoPickerResult], PhotoPickerError>) -> Void
    ) {
        guard let provider else {
            completion(.failure(.providerNotConfigured))
            return
        }
        let vc = provider.makePickerViewController(
            configuration: configuration,
            completion: completion
        )
        viewController.present(vc, animated: animated)
    }

    /// 弹出相机拍摄
    /// - Parameters:
    ///   - viewController: 当前 ViewController
    ///   - configuration: 相机配置，默认使用 `.default`
    ///   - animated: 是否动画弹出，默认 true
    ///   - completion: 拍摄结果回调
    public func presentCamera(
        from viewController: UIViewController,
        configuration: CameraConfiguration = .default,
        animated: Bool = true,
        completion: @escaping @Sendable (Result<PhotoPickerResult, PhotoPickerError>) -> Void
    ) {
        guard let provider else {
            completion(.failure(.providerNotConfigured))
            return
        }
        let vc = provider.makeCameraViewController(
            configuration: configuration,
            completion: completion
        )
        viewController.present(vc, animated: animated)
    }
}
#endif
