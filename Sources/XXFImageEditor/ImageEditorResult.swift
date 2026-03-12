#if canImport(UIKit)
import UIKit

/// 图片编辑完成后的结果
public struct ImageEditorResult: Sendable {

    /// 编辑后的图片
    public let image: UIImage

    public init(image: UIImage) {
        self.image = image
    }
}
#endif
