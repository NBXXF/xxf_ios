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

        let photoPreviewSheet = ZLPhotoPreviewSheet()

        photoPreviewSheet.selectImageBlock = { [weak photoPreviewSheet] (images, assets, isOriginal) in
            guard let sheet = photoPreviewSheet else {
                completion(.failure(.unknown(NSError(domain: "ZLPhotoPicker", code: -1, userInfo: [NSLocalizedDescriptionKey: "选择器已释放"]))))
                return
            }

            // ZLPhotoBrowser 已经处理视频导出，images 数组包含视频封面图
            // 如果需要视频文件，需要通过 PHAsset 导出
            self.processSelectedAssets(
                images: images,
                assets: assets,
                isOriginal: isOriginal,
                sheet: sheet,
                completion: completion
            )
        }

        photoPreviewSheet.cancelBlock = {
            completion(.failure(.cancelled))
        }

        return ZLPhotoPickerWrapperViewController(photoPreviewSheet: photoPreviewSheet)
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

    /// 处理选择的资源（图片/视频）
    private func processSelectedAssets(
        images: [UIImage],
        assets: [PHAsset],
        isOriginal: Bool,
        sheet: ZLPhotoPreviewSheet,
        completion: @escaping @Sendable (Result<[PhotoPickerResult], PhotoPickerError>) -> Void
    ) {
        let dispatchGroup = DispatchGroup()
        var results: [PhotoPickerResult] = []
        var exportError: PhotoPickerError?
        let resultsLock = NSLock()

        for (image, asset) in zip(images, assets) {
            if asset.mediaType == .video {
                // 导出视频
                dispatchGroup.enter()
                exportVideo(asset: asset) { result in
                    switch result {
                    case .success(let url):
                        let videoResult = PhotoPickerResult(
                            mediaType: .video,
                            image: image, // 视频封面
                            videoURL: url,
                            isOriginal: false,
                            assetIdentifier: asset.localIdentifier
                        )
                        resultsLock.lock()
                        results.append(videoResult)
                        resultsLock.unlock()
                    case .failure(let error):
                        resultsLock.lock()
                        exportError = error
                        resultsLock.unlock()
                    }
                    dispatchGroup.leave()
                }
            } else {
                // 图片直接添加到结果
                let photoResult = PhotoPickerResult(
                    mediaType: .image,
                    image: image,
                    videoURL: nil,
                    isOriginal: isOriginal,
                    assetIdentifier: asset.localIdentifier
                )
                results.append(photoResult)
            }
        }

        dispatchGroup.notify(queue: .main) {
            sheet.hide {
                if let error = exportError {
                    completion(.failure(error))
                } else {
                    completion(.success(results))
                }
            }
        }
    }

    /// 导出视频到临时目录
    private func exportVideo(
        asset: PHAsset,
        completion: @escaping (Result<URL, PhotoPickerError>) -> Void
    ) {
        let options = PHVideoRequestOptions()
        options.version = .original
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        PHImageManager.default().requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetHighestQuality) { exportSession, info in
            guard let exportSession = exportSession else {
                completion(.failure(.assetLoadFailed(NSError(domain: "ZLPhotoPicker", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法创建视频导出会话"]))))
                return
            }

            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mp4")
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mp4
            exportSession.shouldOptimizeForNetworkUse = true

            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    completion(.success(outputURL))
                case .failed, .cancelled:
                    completion(.failure(.videoExportFailed(exportSession.error ?? NSError(domain: "ZLPhotoPicker", code: -1))))
                default:
                    break
                }
            }
        }
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

        // 主题色
        if let themeColor = config.themeColor {
            zlConfig.themeColorDeploy.mainColor = themeColor.primaryColor
            if let bgColor = themeColor.backgroundColor {
                zlConfig.themeColorDeploy.previewBgColor = bgColor
            }
            if let textColor = themeColor.textColor {
                zlConfig.themeColorDeploy.previewBtnBgColor = textColor
            }
        }
    }
}

// MARK: - ZLPhotoBrowser Wrapper

/// 包装器，将 ZLPhotoPreviewSheet 包装成 UIViewController
private final class ZLPhotoPickerWrapperViewController: UIViewController {

    private let photoPreviewSheet: ZLPhotoPreviewSheet

    init(photoPreviewSheet: ZLPhotoPreviewSheet) {
        self.photoPreviewSheet = photoPreviewSheet
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
        photoPreviewSheet.showPreview(animate: true, sender: self)
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
