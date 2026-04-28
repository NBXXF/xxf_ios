//
//  ConfigurableCell.swift
//  xxf_ios
//  模型绑定cell协议
//  Created by xxf on 2022/11/12.
//

/// 可配置 Cell 协议
/// 用于将数据模型绑定到 UITableViewCell/UICollectionViewCell
/// 配合 BaseTableViewCell/BaseCollectionViewCell 使用
///
/// 使用示例:
/// ```swift
/// // 1. 定义模型
/// struct User {
///     let name: String
///     let avatar: String
/// }
///
/// // 2. 创建 Cell 继承基类
/// class UserCell: BaseTableViewCell<User> {
///     override func configure(with model: User) {
///         super.configure(with: model)
///         textLabel?.text = model.name
///     }
/// }
///
/// // 3. 在 tableView(_:cellForRowAt:) 中使用
/// let user = users[indexPath.row]
/// cell.configure(with: user, payloads: ["highlight": true])
/// ```
@MainActor
public protocol ConfigurableCell {
    /// 关联类型 - 数据模型类型
    associatedtype Model

    /// 当前绑定的数据模型
    var model: Model? { get set }

    /// 带额外参数配置 Cell 数据
    /// - Parameters:
    ///   - model: 数据模型，用于填充 Cell 内容
    ///   - payloads: 额外的上下文数据，如高亮标记、展开状态等，可用于局部刷新
    func configure(with model: Model, payloads: [Any]?)
}
