import Foundation

/// 图片视频选择过程中可能发生的错误
public enum PhotoPickerError: Error, Sendable {

    /// 用户主动取消，通常可忽略此 case
    case cancelled

    /// 未配置 provider，需先设置 `PhotoPicker.shared.provider`
    case providerNotConfigured

    /// 权限被拒绝
    case permissionDenied

    /// 超过最大选择数量
    case exceededMaxSelection(count: Int)

    /// 加载资源失败
    case assetLoadFailed(Error)

    /// 导出视频失败
    case videoExportFailed(Error)

    /// 未知错误
    case unknown(Error)
}

extension PhotoPickerError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "用户取消选择"

        case .providerNotConfigured:
            return "PhotoPicker provider 未配置。使用前请先设置 PhotoPicker.shared.provider"

        case .permissionDenied:
            return "相册或相机权限被拒绝"

        case .exceededMaxSelection(let count):
            return "超过最大选择数量限制：\(count)"

        case .assetLoadFailed(let error):
            return "加载资源失败：\(error.localizedDescription)"

        case .videoExportFailed(let error):
            return "视频导出失败：\(error.localizedDescription)"

        case .unknown(let error):
            return "未知错误：\(error.localizedDescription)"
        }
    }
}
