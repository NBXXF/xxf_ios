/// 图片编辑器支持的宽高比类型
public enum ImageEditorAspectRatio: Sendable {
    /// 自由比例（用户可任意调整，宽高比选择器可用）
    case freeform
    /// 正方形（1:1）
    case square
    /// 自定义整数比例，例如 `.ratio(width: 16, height: 9)`
    ///
    /// 使用整数避免浮点截断问题（如 `CGFloat(1.78)` → `Int(1)` 导致变成 1:1）。
    case ratio(width: Int, height: Int)
}
