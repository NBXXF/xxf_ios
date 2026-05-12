//
//  StackCompositionalLayout.swift
//  xxf_ios
//
//  Created by xxf on 5/12.
//
#if canImport(UIKit)
import UIKit

/// 叠层组件专用的 compositional layout。
///
/// 根据外部数据数量动态生成 custom group，适合 0...n 个组件的重叠展示。
public final class StackCompositionalLayout: UICollectionViewCompositionalLayout {
    /// 组件叠层的前后关系。
    public enum StackDirection {
        /// 后绘制的组件盖在前一个组件上。
        case ascending
        /// 前绘制的组件盖在后一个组件上。
        case descending
    }

    /// 创建叠层组件布局。
    ///
    /// - Parameters:
    ///   - itemCountProvider: 返回当前要展示的 item 数量，内部会将负数归一到 0。
    ///   - cellSize: 单个组件尺寸，必须大于 0。
    ///   - overlapSpacing: 组件之间的水平错位，必须大于等于 0。
    ///   - stackDirection: 叠层前后关系。
    public init(
        itemCountProvider: @escaping () -> Int,
        cellSize: CGFloat = 36,
        overlapSpacing: CGFloat = 12,
        stackDirection: StackDirection = .ascending
    ) {
        precondition(cellSize > 0, "cellSize must be greater than 0")
        precondition(overlapSpacing >= 0, "overlapSpacing must be greater than or equal to 0")

        super.init(sectionProvider: { [itemCountProvider, cellSize, overlapSpacing, stackDirection] _, _ in
            Self.makeSection(
                itemCount: itemCountProvider(),
                cellSize: cellSize,
                overlapSpacing: overlapSpacing,
                stackDirection: stackDirection
            )
        })
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 在数据变化后显式失效布局。
    public func refreshLayout() {
        invalidateLayout()
    }

    private static func makeSection(
        itemCount: Int,
        cellSize: CGFloat,
        overlapSpacing: CGFloat,
        stackDirection: StackDirection
    ) -> NSCollectionLayoutSection {
        let visibleCount = max(0, itemCount)
        let groupWidth = visibleCount > 0
            ? cellSize + CGFloat(max(visibleCount - 1, 0)) * overlapSpacing
            : 0
        let groupHeight = visibleCount > 0 ? cellSize : 0

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(groupWidth),
            heightDimension: .absolute(groupHeight)
        )

        let group = NSCollectionLayoutGroup.custom(layoutSize: groupSize) { _ in
            guard visibleCount > 0 else { return [] }

            return (0 ..< visibleCount).map { index in
                NSCollectionLayoutGroupCustomItem(
                    frame: CGRect(
                        x: CGFloat(index) * overlapSpacing,
                        y: 0,
                        width: cellSize,
                        height: cellSize
                    ),
                    zIndex: stackDirection == .ascending ? index : visibleCount - index
                )
            }
        }

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .zero
        section.interGroupSpacing = 0
        return section
    }
}
#endif
