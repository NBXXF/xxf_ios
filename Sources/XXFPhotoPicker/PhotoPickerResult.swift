#if canImport(UIKit)
import UIKit
import Photos

/// 图片视频选择结果
public struct PhotoPickerResult: Sendable {

    /// 媒体类型
    public let mediaType: PhotoPickerMediaType

    /// 图片（如果是图片类型）
    public let image: UIImage?

    /// 视频 URL（如果是视频类型）
    public let videoURL: URL?

    /// 是否为原图
    public let isOriginal: Bool

    /// PHAsset 标识符，用于后续获取完整数据
    public let assetIdentifier: String?

    /// 创建图片结果
    public static func image(
        _ image: UIImage,
        isOriginal: Bool = false,
        assetIdentifier: String? = nil
    ) -> PhotoPickerResult {
        PhotoPickerResult(
            mediaType: .image,
            image: image,
            videoURL: nil,
            isOriginal: isOriginal,
            assetIdentifier: assetIdentifier
        )
    }

    /// 创建视频结果
    public static func video(
        url: URL,
        assetIdentifier: String? = nil
    ) -> PhotoPickerResult {
        PhotoPickerResult(
            mediaType: .video,
            image: nil,
            videoURL: url,
            isOriginal: false,
            assetIdentifier: assetIdentifier
        )
    }

    /// 创建混合类型结果（图片+视频）
    public static func mixed(
        image: UIImage?,
        videoURL: URL?,
        isOriginal: Bool = false,
        assetIdentifier: String? = nil
    ) -> PhotoPickerResult {
        let mediaType: PhotoPickerMediaType = videoURL != nil ? .video : .image
        return PhotoPickerResult(
            mediaType: mediaType,
            image: image,
            videoURL: videoURL,
            isOriginal: isOriginal,
            assetIdentifier: assetIdentifier
        )
    }

    public init(
        mediaType: PhotoPickerMediaType,
        image: UIImage?,
        videoURL: URL?,
        isOriginal: Bool,
        assetIdentifier: String?
    ) {
        self.mediaType = mediaType
        self.image = image
        self.videoURL = videoURL
        self.isOriginal = isOriginal
        self.assetIdentifier = assetIdentifier
    }
}
#endif
