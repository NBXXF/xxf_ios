#if canImport(UIKit)
import UIKit

/// 图片视频选择器配置
public struct PhotoPickerConfiguration: Sendable {

    /// 媒体类型
    public var mediaType: PhotoPickerMediaType

    /// 选择模式
    public var selectionMode: PhotoPickerSelectionMode

    /// 最大选择数量（仅在多选模式下有效）
    public var maxSelectionCount: Int

    /// 是否允许选择原图
    public var allowSelectOriginal: Bool

    /// 是否允许拍摄照片
    public var allowTakePhoto: Bool

    /// 是否允许拍摄视频
    public var allowTakeVideo: Bool

    /// 裁剪配置（单选图片时有效）
    public var cropConfiguration: PhotoCropConfiguration?

    /// 主题色调
    public var themeColor: PhotoPickerColor?

    /// 默认配置
    public static let `default` = PhotoPickerConfiguration()

    public init(
        mediaType: PhotoPickerMediaType = .image,
        selectionMode: PhotoPickerSelectionMode = .single,
        maxSelectionCount: Int = 9,
        allowSelectOriginal: Bool = true,
        allowTakePhoto: Bool = true,
        allowTakeVideo: Bool = true,
        cropConfiguration: PhotoCropConfiguration? = nil,
        themeColor: PhotoPickerColor? = nil
    ) {
        self.mediaType = mediaType
        self.selectionMode = selectionMode
        self.maxSelectionCount = max(maxSelectionCount, 1)
        self.allowSelectOriginal = allowSelectOriginal
        self.allowTakePhoto = allowTakePhoto
        self.allowTakeVideo = allowTakeVideo
        self.cropConfiguration = cropConfiguration
        self.themeColor = themeColor
    }
}

/// 相机配置
public struct CameraConfiguration: Sendable {

    /// 媒体类型
    public var mediaType: PhotoPickerMediaType

    /// 是否允许切换摄像头
    public var allowSwitchCamera: Bool

    /// 默认配置
    public static let `default` = CameraConfiguration()

    public init(
        mediaType: PhotoPickerMediaType = .image,
        allowSwitchCamera: Bool = true
    ) {
        self.mediaType = mediaType
        self.allowSwitchCamera = allowSwitchCamera
    }
}

/// 裁剪配置
///
/// - Note: 与 ImageCropConfiguration 保持命名一致，使用 `isResizable` 而非 `allowFreeRatio`
public struct PhotoCropConfiguration: Sendable {

    /// 宽高比约束，默认自由比例
    public var aspectRatio: PhotoPickerAspectRatio

    /// 是否允许用户手动调整裁剪区域大小，默认 true
    ///
    /// - Note: 此属性的实际效果由具体 Provider 实现决定
    public var isResizable: Bool

    /// 默认配置
    public static let `default` = PhotoCropConfiguration()

    public init(
        aspectRatio: PhotoPickerAspectRatio = .freeform,
        isResizable: Bool = true
    ) {
        self.aspectRatio = aspectRatio
        self.isResizable = isResizable
    }
}

/// 颜色配置
public struct PhotoPickerColor: Sendable {

    /// 主色调
    public let primaryColor: UIColor

    /// 背景色
    public let backgroundColor: UIColor?

    /// 文字颜色
    public let textColor: UIColor?

    public init(
        primaryColor: UIColor,
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil
    ) {
        self.primaryColor = primaryColor
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
}
#endif
