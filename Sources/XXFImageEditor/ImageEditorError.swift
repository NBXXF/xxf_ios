import Foundation

/// 图片编辑过程中可能发生的错误
public enum ImageEditorError: Error, Sendable {
    /// 用户主动取消，通常可忽略此 case
    case cancelled
    /// 未配置 provider，需先设置 `ImageEditor.shared.provider`
    case providerNotConfigured
    /// 渲染失败
    case renderingFailed(Error)
}

extension ImageEditorError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Operation cancelled by user."
        case .providerNotConfigured:
            return "ImageEditor provider is not configured. Set ImageEditor.shared.provider before use."
        case .renderingFailed(let error):
            return "Image rendering failed: \(error.localizedDescription)"
        }
    }
}
