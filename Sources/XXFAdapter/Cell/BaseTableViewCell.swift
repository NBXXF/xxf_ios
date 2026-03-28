//
//  BaseTableViewCell.swift
//  xxf_ios
//
//  Created by xxf on 2022/11/12.
//

#if canImport(UIKit)

/// UITableViewCell 的基类，统一实现 ConfigurableCell

open class BaseTableViewCell<Model>: UITableViewCell, ConfigurableCell {
    public typealias Model = Model

    // MARK: - 数据绑定

    /// 当前绑定的数据模型，便于其他方法访问
    open private(set) var model: Model?

    /// 基础配置，存储 model
    open func configure(with model: Model) {
        self.model = model
    }

    /// 带额外参数的配置，子类可重写以实现局部刷新
    open func configure(with model: Model, payloads: [Any]) {
        configure(with: model)
        // 子类处理 payloads 实现局部刷新
    }

    // MARK: - 复用处理

    override open func prepareForReuse() {
        super.prepareForReuse()
        model = nil
    }

    // 构造函数
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
#endif
