//
//  NSCollectionLayoutSection+Ext.swift
//  xxf_ios
//
//  Created by xxf on 5/12.
//

//  CollectionView compositional layout 的 supplementary 便捷封装。
//
#if canImport(UIKit)
import UIKit

public extension NSCollectionLayoutSection {
    /// 给 section 添加一个自适应高度的 header。
    ///
    /// - 入口: `HostedSupplementaryView.addSelfSizingHeader(...)`
    /// - 高度: 只传 `estimatedHeight`，最终高度由宿主测量
    /// - 行为: 替换同 kind + 同位置的旧补充视图
    func addSelfSizingHeader(
        estimatedHeight: CGFloat,
        kind: String = UICollectionView.elementKindSectionHeader,
        pinToVisibleBounds: Bool = false
    ) {
        addSelfSizingBoundarySupplementary(
            kind: kind,
            alignment: .top,
            estimatedHeight: estimatedHeight,
            pinToVisibleBounds: pinToVisibleBounds
        )
    }

    /// 给 section 添加一个自适应高度的 footer。
    ///
    /// - 入口: `HostedSupplementaryView.addSelfSizingFooter(...)`
    /// - 高度: 只传 `estimatedHeight`，最终高度由宿主测量
    /// - 行为: 替换同 kind + 同位置的旧补充视图
    func addSelfSizingFooter(
        estimatedHeight: CGFloat,
        kind: String = UICollectionView.elementKindSectionFooter,
        pinToVisibleBounds: Bool = false
    ) {
        addSelfSizingBoundarySupplementary(
            kind: kind,
            alignment: .bottom,
            estimatedHeight: estimatedHeight,
            pinToVisibleBounds: pinToVisibleBounds
        )
    }

    /// 给 section 添加一个自适应高度的边界补充视图。
    ///
    /// 这是 header/footer 的底层实现。
    /// 它会替换同 kind + 同 alignment 的旧补充视图，避免重复叠加。
    private func addSelfSizingBoundarySupplementary(
        kind: String,
        alignment: NSRectAlignment,
        estimatedHeight: CGFloat,
        pinToVisibleBounds: Bool
    ) {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedHeight)
        )
        let item = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: size,
            elementKind: kind,
            alignment: alignment
        )
        item.pinToVisibleBounds = pinToVisibleBounds
        boundarySupplementaryItems.removeAll { $0.elementKind == kind && $0.alignment == alignment }
        boundarySupplementaryItems.append(item)
    }
}
#endif
