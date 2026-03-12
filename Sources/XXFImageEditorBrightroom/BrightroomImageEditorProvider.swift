#if canImport(UIKit)
import UIKit
import BrightroomEngine
import BrightroomUI
import XXFImageEditor

/// 基于 Brightroom 2.x 的图片编辑器 Provider（iOS 13+）
///
/// 在应用启动时注册：
/// ```swift
/// ImageEditor.shared.provider = BrightroomImageEditorProvider()
/// ```
@MainActor
public final class BrightroomImageEditorProvider: ImageEditorProvider {

    public init() {}

    // MARK: - ImageEditorProvider

    public func makeEditorViewController(
        image: UIImage,
        configuration: ImageEditorConfiguration,
        completion: @escaping @Sendable (Result<ImageEditorResult, ImageEditorError>) -> Void
    ) -> UIViewController {
        let stack = makeEditingStack(image: image)
        let vc = ClassicImageEditViewController(editingStack: stack)
        vc.handlers.didEndEditing = { [weak vc] (_: ClassicImageEditViewController, stack: EditingStack) -> Void in
            vc?.dismiss(animated: true)
            BrightroomImageEditorProvider.render(stack: stack, completion: completion)
        }
        vc.handlers.didCancelEditing = { [weak vc] (_: ClassicImageEditViewController) -> Void in
            vc?.dismiss(animated: true)
            completion(.failure(.cancelled))
        }
        return vc
    }

    public func makeCropViewController(
        image: UIImage,
        configuration: ImageCropConfiguration,
        completion: @escaping @Sendable (Result<ImageEditorResult, ImageEditorError>) -> Void
    ) -> UIViewController {
        var options = PhotosCropViewController.Options()
        options.aspectRatioOptions = configuration.aspectRatio.brightroomAspectRatioOptions
        let stack = makeEditingStack(image: image)
        let vc = PhotosCropViewController(editingStack: stack, options: options)
        vc.handlers.didFinish = { [weak vc] (cropVC: PhotosCropViewController) -> Void in
            cropVC.renderImage(options: BrightRoomImageRenderer.Options()) { result in
                vc?.dismiss(animated: true)
                switch result {
                case .success(let rendered):
                    completion(.success(ImageEditorResult(image: rendered.uiImage)))
                case .failure(let error):
                    completion(.failure(.renderingFailed(error)))
                }
            }
        }
        vc.handlers.didCancel = { [weak vc] (_: PhotosCropViewController) -> Void in
            vc?.dismiss(animated: true)
            completion(.failure(.cancelled))
        }
        return vc
    }

    // MARK: - Private

    private func makeEditingStack(image: UIImage) -> EditingStack {
        EditingStack(imageProvider: ImageProvider(image: image))
    }

    private static func render(
        stack: EditingStack,
        completion: @escaping @Sendable (Result<ImageEditorResult, ImageEditorError>) -> Void
    ) {
        do {
            try stack.makeRenderer().render(options: BrightRoomImageRenderer.Options()) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let rendered):
                        completion(.success(ImageEditorResult(image: rendered.uiImage)))
                    case .failure(let error):
                        completion(.failure(.renderingFailed(error)))
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(.renderingFailed(error)))
            }
        }
    }
}

// MARK: - ImageEditorAspectRatio → Brightroom Options

extension ImageEditorAspectRatio {
    fileprivate var brightroomAspectRatioOptions: PhotosCropViewController.Options.AspectRatioOptions {
        switch self {
        case .freeform:
            return .selectable
        case .square:
            return .fixed(PixelAspectRatio(width: CGFloat(1), height: CGFloat(1)))
        case .ratio(let w, let h):
            return .fixed(PixelAspectRatio(width: CGFloat(w), height: CGFloat(h)))
        }
    }
}
#endif
