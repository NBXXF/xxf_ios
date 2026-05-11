//
//  UICollectionView+Scroll.swift
//  xxf_ios
//
//  Created by xxf on 5/11.
//

#if canImport(UIKit)
import UIKit

public extension UICollectionView {
    /// 业务语义滚动位置：
    /// - start: 起始端（横向 left / 纵向 top）
    /// - center: 中间（按方向居中）
    /// - end: 末端（横向 right / 纵向 bottom）
    enum AnchorScrollPosition {
        case start
        case center
        case end
    }

    /// 滚动到指定 section 的第一个 item。
    func scrollToStart(
        inSection section: Int = 0,
        at: AnchorScrollPosition = .start,
        scrollDirection: UICollectionView.ScrollDirection,
        animated: Bool = false
    ) {
        guard section >= 0, section < numberOfSections else {
            assertionFailure("UICollectionView.scrollToStart invalid section: \(section), numberOfSections: \(numberOfSections)")
            return
        }
        let itemCount = numberOfItems(inSection: section)
        guard itemCount > 0 else { return }
        let firstIndexPath = IndexPath(item: 0, section: section)
        scrollToItem(at: firstIndexPath, at: at, scrollDirection: scrollDirection, animated: animated)
    }

    /// 滚动到指定 section 的最后一个 item。
    func scrollToEnd(
        inSection section: Int = 0,
        at: AnchorScrollPosition = .end,
        scrollDirection: UICollectionView.ScrollDirection,
        animated: Bool = false
    ) {
        guard section >= 0, section < numberOfSections else {
            assertionFailure("UICollectionView.scrollToEnd invalid section: \(section), numberOfSections: \(numberOfSections)")
            return
        }
        let itemCount = numberOfItems(inSection: section)
        guard itemCount > 0 else { return }
        let lastIndexPath = IndexPath(item: itemCount - 1, section: section)
        scrollToItem(at: lastIndexPath, at: at, scrollDirection: scrollDirection, animated: animated)
    }

    /// 按业务语义位置滚动到指定 item。
    func scrollToItem(
        at indexPath: IndexPath,
        at logicalScrollPosition: AnchorScrollPosition,
        scrollDirection: UICollectionView.ScrollDirection,
        animated: Bool
    ) {
        guard indexPath.section >= 0, indexPath.section < numberOfSections else {
            assertionFailure("UICollectionView.scrollToItem invalid section: \(indexPath.section), numberOfSections: \(numberOfSections)")
            return
        }
        let itemCount = numberOfItems(inSection: indexPath.section)
        guard indexPath.item >= 0, indexPath.item < itemCount else {
            assertionFailure("UICollectionView.scrollToItem invalid item: \(indexPath.item), itemCount: \(itemCount), section: \(indexPath.section)")
            return
        }
        scrollToItem(
            at: indexPath,
            at: logicalScrollPosition.scrollPosition(direction: scrollDirection),
            animated: animated
        )
    }
}

private extension UICollectionView.AnchorScrollPosition {
    /// 将业务语义位置映射到 UIKit 的滚动锚点。
    func scrollPosition(direction: UICollectionView.ScrollDirection) -> UICollectionView.ScrollPosition {
        switch direction {
        case .horizontal:
            switch self {
            case .start:
                return .left
            case .center:
                return .centeredHorizontally
            case .end:
                return .right
            }
        case .vertical:
            switch self {
            case .start:
                return .top
            case .center:
                return .centeredVertically
            case .end:
                return .bottom
            }
        @unknown default:
            // 兼容未来系统新增方向 case，按纵向语义兜底，确保 Swift 6 可编译。
            switch self {
            case .start:
                return .top
            case .center:
                return .centeredVertically
            case .end:
                return .bottom
            }
        }
    }
}
#endif
