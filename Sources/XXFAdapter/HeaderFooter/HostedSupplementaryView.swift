//
//  HostedSupplementaryView.swift
//  xxf_ios
//
//  Created by xxf on 5/12.
//

//  通用 CollectionView Supplementary 宿主视图。
//  用于把任意自定义 UIView 挂到 header / footer 上，并通过 Auto Layout 自适应高度。
//
#if canImport(UIKit)
import UIKit

/// 通用 CollectionView Supplementary 宿主视图。
///
/// 这个类型只负责“承载”自定义 `UIView`，不包含具体业务内容。
/// 目标是把任意 header / footer 内容以标准的 `UICollectionReusableView`
/// 形式接入 `UICollectionViewCompositionalLayout`，并通过 Auto Layout 自动测高。
///
/// 使用方式:
/// ```swift
/// let contentView = CustomHeaderView()
///
/// collectionView.register(
///     supplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
///     withClass: HostedSupplementaryView.self
/// )
///
/// dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
///     guard kind == UICollectionView.elementKindSectionHeader, let self else { return nil }
///     let view = collectionView.dequeueReusableSupplementaryView(
///         ofKind: kind,
///         withClass: HostedSupplementaryView.self,
///         for: indexPath
///     )
///     view.setContent(contentView)
///     return view
/// }
///
/// HostedSupplementaryView.addSelfSizingHeader(
///     section: section,
///     estimatedHeight: 180.pt
/// )
///
/// contentView.configure(with: model)
/// collectionView.collectionViewLayout.invalidateLayout()
/// ```
///
/// 这段伪代码表达的顺序是:
/// - 先准备业务内容 view
/// - 再注册并 dequeue 宿主 view
/// - 宿主只负责承载和测高
/// - section 通过 `addSelfSizingHeader` / `addSelfSizingFooter` 提供估算高度
/// - 内容变化后只更新内容并重算 layout
///
/// 高度入口:
/// - 唯一入口是 `HostedSupplementaryView.addSelfSizingHeader(...)`
///   / `HostedSupplementaryView.addSelfSizingFooter(...)`
/// - 外部只提供 `estimatedHeight`，不要硬编码最终高度
///
/// 测量方式:
/// - layout 先给 estimated 尺寸
/// - 系统调用 `preferredLayoutAttributesFitting(_:)`
/// - 宿主用内容视图的 Auto Layout 计算最终高度
///
/// 注意事项:
/// - 内容视图必须约束闭合
/// - 同一个 view 只挂一个宿主
/// - 内容变更后记得 `invalidateLayout()`
public final class HostedSupplementaryView: UICollectionReusableView {
    /// 当前承载的内容视图。
    ///
    /// 这个引用用于复用时判断是否重复挂载同一个 view，以及在切换内容时清理旧视图。
    private var hostedView: UIView?
    /// 当前内容视图挂在宿主上的边缘约束。
    ///
    /// 复用或替换内容时会统一 deactivate，避免旧约束残留影响后续测高。
    private var hostedConstraints: [NSLayoutConstraint] = []

    /// 清理复用前残留的内容和约束。
    ///
    /// 这个方法会在 UICollectionView 复用 supplementary view 时自动调用。
    /// 外部一般不需要手动调用。
    override public func prepareForReuse() {
        super.prepareForReuse()
        NSLayoutConstraint.deactivate(hostedConstraints)
        hostedConstraints.removeAll()
        hostedView?.removeFromSuperview()
        hostedView = nil
    }

    /// 设置要承载的内容视图。
    ///
    /// 这是宿主的核心入口。调用者在 dequeue 到 `HostedSupplementaryView`
    /// 之后，把真正的 header / footer 内容 view 传进来即可。
    ///
    /// - Parameter view: 已完成子视图与内部约束搭建的自定义 view。
    ///   宿主只负责把它挂到自己身上，并让它参与 Auto Layout 测高。
    /// - Important: 传入的 view 会被四边 pin 到宿主自身边界，因此内容 view
    ///   必须能仅靠约束推导出最终高度。
    public func setContent(_ view: UIView) {
        guard hostedView !== view else { return }

        NSLayoutConstraint.deactivate(hostedConstraints)
        hostedConstraints.removeAll()
        hostedView?.removeFromSuperview()
        hostedView = view

        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        hostedConstraints = [
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]
        NSLayoutConstraint.activate(hostedConstraints)
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    /// 根据内容视图的 Auto Layout 结果计算 supplementary 的最终高度。
    ///
    /// UIKit / Compositional Layout 在需要确定 header / footer 最终尺寸时会自动调用这个方法。
    /// 这里不需要外部手动调用；只要提供了 `estimated` 高度，系统就会走到这里完成二次测量。
    ///
    /// - Parameter layoutAttributes: layout 先给出的预估尺寸。
    /// - Returns: 以内容视图实际约束为准的最终尺寸。
    /// - Important:
    ///   - 测高依据是 `hostedView.systemLayoutSizeFitting(...)`
    ///   - 如果内容 view 的约束不完整，测量结果会不稳定
    ///   - 外部不应该再对这个 supplementary 手算固定高度
    override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
        guard let hostedView else { return attrs }

        let targetSize = CGSize(
            width: attrs.size.width,
            height: UIView.layoutFittingCompressedSize.height
        )
        let fitting = hostedView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        attrs.size.height = ceil(fitting.height)
        return attrs
    }
}

public extension HostedSupplementaryView {
    /// 给 `NSCollectionLayoutSection` 快速挂一个自适应高度的 header。
    ///
    /// 这个方法只是一个语义化转发，真正的 layout 构建仍然交给
    /// `NSCollectionLayoutSection.addSelfSizingHeader(...)`。
    /// 之所以挂在 `HostedSupplementaryView` 命名空间下，是为了让调用点更接近
    /// “header 宿主 + 自适应 header” 这一组概念，减少业务代码里对 layout 细节的暴露。
    ///
    /// 使用场景:
    /// - 业务代码已经决定使用 `HostedSupplementaryView` 承载 header 内容
    /// - 这里只想在 section 上快速补上一个 `estimated` 高度的 header
    /// - 不要在外部再单独写最终高度，header 高度统一走这个入口
    ///
    /// - Parameters:
    ///   - section: 需要添加 header 的 compositional layout section。
    ///   - estimatedHeight: header 的初始估算高度。真实高度仍由 `HostedSupplementaryView`
    ///     在 `preferredLayoutAttributesFitting(_:)` 中根据内容视图的 Auto Layout 测出来。
    ///   - kind: supplementary 的 kind，默认是 section header。
    ///   - pinToVisibleBounds: 是否吸顶，默认 false。
    static func addSelfSizingHeader(
        section: NSCollectionLayoutSection,
        estimatedHeight: CGFloat,
        kind: String = UICollectionView.elementKindSectionHeader,
        pinToVisibleBounds: Bool = false
    ) {
        section.addSelfSizingHeader(estimatedHeight: estimatedHeight, kind: kind, pinToVisibleBounds: pinToVisibleBounds)
    }

    /// 给 `NSCollectionLayoutSection` 快速挂一个自适应高度的 footer。
    ///
    /// 这和 `addSelfSizingHeader(section:estimatedHeight:kind:pinToVisibleBounds:)` 是对称入口，
    /// 只是把补充视图放到 section 底部。业务侧如果要放一个 footer 内容视图，
    /// 可以直接走这个方法，不需要关心 compositional layout 的底层细节。
    /// footer 高度同样通过这里传入 `estimatedHeight`，不要硬编码最终值。
    ///
    /// - Parameters:
    ///   - section: 需要添加 footer 的 compositional layout section。
    ///   - estimatedHeight: footer 的初始估算高度。真实高度仍由 `HostedSupplementaryView`
    ///     在 `preferredLayoutAttributesFitting(_:)` 中根据内容视图的 Auto Layout 测出来。
    ///   - kind: supplementary 的 kind，默认是 section footer。
    ///   - pinToVisibleBounds: 是否吸底吸附，默认 false。
    static func addSelfSizingFooter(
        section: NSCollectionLayoutSection,
        estimatedHeight: CGFloat,
        kind: String = UICollectionView.elementKindSectionFooter,
        pinToVisibleBounds: Bool = false
    ) {
        section.addSelfSizingFooter(estimatedHeight: estimatedHeight, kind: kind, pinToVisibleBounds: pinToVisibleBounds)
    }
}
#endif
