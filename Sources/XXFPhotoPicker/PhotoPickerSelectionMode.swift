import Foundation

/// 选择模式
public enum PhotoPickerSelectionMode: Sendable {

    /// 单选
    case single

    /// 多选
    case multiple

    /// 是否为单选
    public var isSingle: Bool {
        switch self {
        case .single: return true
        case .multiple: return false
        }
    }

    /// 是否为多选
    public var isMultiple: Bool {
        !isSingle
    }
}
