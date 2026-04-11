import Foundation

/// 媒体类型
public enum PhotoPickerMediaType: Sendable {

    /// 仅图片
    case image

    /// 仅视频
    case video

    /// 图片和视频混合
    case mixed

    /// 是否包含图片
    public var allowsImage: Bool {
        switch self {
        case .image, .mixed: return true
        case .video: return false
        }
    }

    /// 是否包含视频
    public var allowsVideo: Bool {
        switch self {
        case .video, .mixed: return true
        case .image: return false
        }
    }
}
