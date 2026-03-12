/// 裁切功能配置
public struct ImageCropConfiguration: Sendable {

    /// 宽高比约束，默认自由比例
    public var aspectRatio: ImageEditorAspectRatio

    /// 是否允许用户手动调整裁切区域大小，默认 true
    ///
    /// - Note: 此属性的实际效果由具体 Provider 实现决定。
    ///   部分 Provider（如 BrightroomImageEditorProvider）当前忽略此属性，
    ///   用户始终可以自由调整裁切框大小（仅比例被锁定）。
    public var isResizable: Bool

    public static let `default` = ImageCropConfiguration()

    public init(
        aspectRatio: ImageEditorAspectRatio = .freeform,
        isResizable: Bool = true
    ) {
        self.aspectRatio = aspectRatio
        self.isResizable = isResizable
    }
}
