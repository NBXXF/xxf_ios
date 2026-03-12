/// 完整图片编辑器配置
public struct ImageEditorConfiguration: Sendable {

    /// 裁切子配置
    public var cropConfiguration: ImageCropConfiguration

    public static let `default` = ImageEditorConfiguration()

    public init(cropConfiguration: ImageCropConfiguration = .default) {
        self.cropConfiguration = cropConfiguration
    }
}
