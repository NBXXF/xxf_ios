import Foundation

/// 图片选择器支持的宽高比类型
///
/// - Note: 与 ImageEditorAspectRatio 保持一致，便于用户在使用图片编辑器时无需学习新的 API
public enum PhotoPickerAspectRatio: Sendable {

    /// 自由比例
    case freeform

    /// 正方形 1:1
    case square

    /// 自定义整数比例，例如 `.ratio(width: 16, height: 9)`
    ///
    /// 使用整数避免浮点截断问题
    case ratio(width: Int, height: Int)

    /// 常用比例：4:3
    public static let ratio4x3 = PhotoPickerAspectRatio.ratio(width: 4, height: 3)

    /// 常用比例：3:4
    public static let ratio3x4 = PhotoPickerAspectRatio.ratio(width: 3, height: 4)

    /// 常用比例：16:9
    public static let ratio16x9 = PhotoPickerAspectRatio.ratio(width: 16, height: 9)

    /// 常用比例：9:16
    public static let ratio9x16 = PhotoPickerAspectRatio.ratio(width: 9, height: 16)

    /// 常用比例：3:2
    public static let ratio3x2 = PhotoPickerAspectRatio.ratio(width: 3, height: 2)

    /// 常用比例：2:3
    public static let ratio2x3 = PhotoPickerAspectRatio.ratio(width: 2, height: 3)
}
