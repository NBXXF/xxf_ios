#if canImport(UIKit)
import UIKit
import Photos
import AVFoundation
import ZLPhotoBrowser
import XXFPhotoPicker

/// 基于 ZLPhotoBrowser 4.x 的图片视频选择器 Provider（iOS 13+）
///
/// 在应用启动时注册：
/// ```swift
/// import XXFPhotoPickerZl
/// PhotoPicker.shared.provider = ZLPhotoPickerProvider()
/// ```
@MainActor
public final class ZLPhotoPickerProvider: PhotoPickerProvider {

    public init() {}

    // MARK: - PhotoPickerProvider

    public func makePickerViewController(
        configuration: PhotoPickerConfiguration,
        completion: @escaping @Sendable (Result<[PhotoPickerResult], PhotoPickerError>) -> Void
    ) -> UIViewController {
        // 应用自定义配置
        applyConfiguration(configuration)

        let photoPicker = ZLPhotoPicker()

        photoPicker.selectImageBlock = { [weak photoPicker] (results, isOriginal) in
            guard let picker = photoPicker else {
                completion(.failure(.unknown(NSError(domain: "ZLPhotoPicker", code: -1, userInfo: [NSLocalizedDescriptionKey: "选择器已释放"]))))
                return
            }

            // 处理选择的资源
            self.processResults(
                results: results,
                isOriginal: isOriginal,
                picker: picker,
                completion: completion
            )
        }

        photoPicker.cancelBlock = {
            completion(.failure(.cancelled))
        }

        return ZLPhotoPickerWrapperViewController(photoPicker: photoPicker)
    }

    public func makeCameraViewController(
        configuration: CameraConfiguration,
        completion: @escaping @Sendable (Result<PhotoPickerResult, PhotoPickerError>) -> Void
    ) -> UIViewController {
        // 配置相机
        let cameraConfig = ZLPhotoConfiguration.default().cameraConfiguration
        cameraConfig.allowTakePhoto = configuration.mediaType.allowsImage
        cameraConfig.allowRecordVideo = configuration.mediaType.allowsVideo
        cameraConfig.allowSwitchCamera = configuration.allowSwitchCamera

        let camera = ZLCustomCamera()

        camera.takeDoneBlock = { [weak camera] (image, url) in
            if let image = image {
                let result = PhotoPickerResult.image(image)
                completion(.success(result))
            } else if let url = url {
                let result = PhotoPickerResult.video(url: url)
                completion(.success(result))
            } else {
                completion(.failure(.unknown(NSError(domain: "ZLPhotoPicker", code: -1, userInfo: [NSLocalizedDescriptionKey: "相机拍摄返回空数据"]))))
            }
            camera?.dismiss(animated: true)
        }

        camera.cancelBlock = {
            completion(.failure(.cancelled))
        }

        return camera
    }

    // MARK: - Private

    /// 处理选择的结果
    private func processResults(
        results: [ZLResultModel],
        isOriginal: Bool,
        picker: ZLPhotoPicker,
        completion: @escaping @Sendable (Result<[PhotoPickerResult], PhotoPickerError>) -> Void
    ) {
        let photoResults: [PhotoPickerResult] = results.map { result in
            if result.asset.mediaType == .video {
                return PhotoPickerResult(
                    mediaType: .video,
                    image: result.image,
                    videoURL: nil,  // ZLPhotoBrowser 已经处理视频，这里返回封面图
                    isOriginal: false,
                    assetIdentifier: result.asset.localIdentifier
                )
            } else {
                return PhotoPickerResult(
                    mediaType: .image,
                    image: result.image,
                    videoURL: nil,
                    isOriginal: isOriginal,
                    assetIdentifier: result.asset.localIdentifier
                )
            }
        }

        completion(.success(photoResults))
    }

    private func applyConfiguration(_ config: PhotoPickerConfiguration) {
        // 重置配置以避免与其他调用互相影响
        ZLPhotoConfiguration.resetConfiguration()

        let zlConfig = ZLPhotoConfiguration.default()

        // 媒体类型
        switch config.mediaType {
        case .image:
            zlConfig.allowSelectImage = true
            zlConfig.allowSelectVideo = false
        case .video:
            zlConfig.allowSelectImage = false
            zlConfig.allowSelectVideo = true
        case .mixed:
            zlConfig.allowSelectImage = true
            zlConfig.allowSelectVideo = true
        }

        // 选择模式
        switch config.selectionMode {
        case .single:
            zlConfig.maxSelectCount = 1
            zlConfig.allowSelectGif = false
            zlConfig.allowSelectLivePhoto = false
        case .multiple:
            zlConfig.maxSelectCount = config.maxSelectionCount
        }

        // 原图选项
        zlConfig.allowSelectOriginal = config.allowSelectOriginal

        // 拍摄选项
        zlConfig.allowTakePhotoInLibrary = config.allowTakePhoto

        // 相机录制视频配置
        zlConfig.cameraConfiguration.allowRecordVideo = config.allowTakeVideo

        // 裁剪配置
        if let cropConfig = config.cropConfiguration {
            zlConfig.allowEditImage = true
            zlConfig.editImageConfiguration.tools = [.clip]

            // 设置裁剪比例
            if !cropConfig.isResizable {
                let ratio = cropConfig.aspectRatio.zlCropRatio
                zlConfig.editImageConfiguration.clipRatios = [ratio]
            }
        } else {
            zlConfig.allowEditImage = false
        }

        // 主题色（在 ZLPhotoUIConfiguration 中设置）
        if let themeColor = config.themeColor {
            let uiConfig = ZLPhotoUIConfiguration.default()
            uiConfig.themeColor = themeColor.primaryColor
            if let bgColor = themeColor.backgroundColor {
                uiConfig.previewVCBgColor = bgColor
            }
        }
    }
}

// MARK: - ZLPhotoBrowser Wrapper

/// 包装器，将 ZLPhotoPicker 包装成 UIViewController
private final class ZLPhotoPickerWrapperViewController: UIViewController {

    private let photoPicker: ZLPhotoPicker

    init(photoPicker: ZLPhotoPicker) {
        self.photoPicker = photoPicker
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        photoPicker.showPreview(animate: true, sender: self)
    }
}

// MARK: - PhotoPickerAspectRatio → ZLPhotoBrowser Ratio

extension PhotoPickerAspectRatio {
    fileprivate var zlCropRatio: ZLImageClipRatio {
        switch self {
        case .freeform:
            return ZLImageClipRatio(title: "自由", whRatio: 0)
        case .square:
            return ZLImageClipRatio.wh1x1
        case .ratio(let width, let height):
            return ZLImageClipRatio(title: "\(width):\(height)", whRatio: CGFloat(width) / CGFloat(height))
        }
    }
}
#endif
