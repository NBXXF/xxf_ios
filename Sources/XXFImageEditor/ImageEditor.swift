#if canImport(UIKit)
import UIKit

/// 图片编辑器门面
///
/// 使用方式：
/// ```swift
/// // 初始化时注册 provider（只需一次，通常在 AppDelegate）
/// import XXFImageEditorBrightroom
/// ImageEditor.shared.provider = BrightroomImageEditorProvider()
///
/// // 使用（只需 import XXFImageEditor）
/// ImageEditor.shared.presentCrop(from: self, image: image) { result in
///     switch result {
///     case .success(let r): print(r.image)
///     case .failure(let e): print(e)
///     }
/// }
/// ```
@MainActor
public final class ImageEditor {

    /// 全局共享实例
    public static let shared = ImageEditor()

    /// 底层实现 Provider，替换此属性即可切换编辑库，无需修改调用方代码
    public var provider: (any ImageEditorProvider)?

    private init() {}

    // MARK: - Present Editor

    /// 弹出完整图片编辑器（支持滤镜、调色、裁切等）
    /// - Parameters:
    ///   - viewController: 当前 ViewController
    ///   - image: 待编辑的图片
    ///   - configuration: 编辑器配置，默认使用 `.default`
    ///   - animated: 是否动画弹出，默认 true
    ///   - completion: 编辑结果回调
    public func presentEditor(
        from viewController: UIViewController,
        image: UIImage,
        configuration: ImageEditorConfiguration = .default,
        animated: Bool = true,
        completion: @escaping @Sendable (Result<ImageEditorResult, ImageEditorError>) -> Void
    ) {
        guard let provider else {
            completion(.failure(.providerNotConfigured))
            return
        }
        let vc = provider.makeEditorViewController(
            image: image,
            configuration: configuration,
            completion: completion
        )
        viewController.present(vc, animated: animated)
    }

    // MARK: - Present Crop

    /// 弹出纯裁切界面
    /// - Parameters:
    ///   - viewController: 当前 ViewController
    ///   - image: 待裁切的图片
    ///   - configuration: 裁切配置，默认使用 `.default`
    ///   - animated: 是否动画弹出，默认 true
    ///   - completion: 裁切结果回调
    public func presentCrop(
        from viewController: UIViewController,
        image: UIImage,
        configuration: ImageCropConfiguration = .default,
        animated: Bool = true,
        completion: @escaping @Sendable (Result<ImageEditorResult, ImageEditorError>) -> Void
    ) {
        guard let provider else {
            completion(.failure(.providerNotConfigured))
            return
        }
        let vc = provider.makeCropViewController(
            image: image,
            configuration: configuration,
            completion: completion
        )
        viewController.present(vc, animated: animated)
    }
}
#endif
