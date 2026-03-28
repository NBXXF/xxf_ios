//
//  ConfigurableCell.swift
//  xxf_ios
//  模型绑定cell
//  Created by xxf on 2022/11/12.
//
#if canImport(UIKit)
import UIKit

// BaseCell 继承 UICollectionViewCell，同时实现 ConfigurableCell 协议
open class BaseCollectionViewCell<Model>: UICollectionViewCell, ConfigurableCell {
    // 协议要求的类型别名
    public typealias Model = Model

    // MARK: - 数据绑定

    /// 当前绑定的数据模型，便于其他方法访问
    open var model: Model?

    /// 带额外参数的配置，子类可重写以实现局部刷新
    open func configure(with model: Model, payloads: [Any]?) {
        self.model = model
        // 子类处理 payloads 实现局部刷新
    }

    // MARK: - 复用处理

    override open func prepareForReuse() {
        super.prepareForReuse()
        model = nil
    }
}
#endif
