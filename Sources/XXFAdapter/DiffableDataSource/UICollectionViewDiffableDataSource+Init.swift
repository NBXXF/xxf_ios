//
//  UICollectionViewDiffableDataSource+Init.swift
//  xxf_ios
//
//  Created by xxf on 5/8.
//

#if canImport(UIKit)
import UIKit

@available(iOS 13.0, *)
@MainActor
public extension UICollectionViewDiffableDataSource {
    /// 参考ensureSection 注释
    convenience init(
        collectionView: UICollectionView,
        initialSection: SectionIdentifierType?,
        animateInitialSectionInsertion: Bool = false,
        cellProvider: @escaping CellProvider
    ) {
        self.init(collectionView: collectionView, cellProvider: cellProvider)
        guard let initialSection else { return }
        ensureSection(initialSection, animatingDifferences: animateInitialSectionInsertion)
    }

    /// Ensure the snapshot contains the given section.
    ///
    /// Why / 为什么要调用:
    /// Some custom layouts query `numberOfItems(inSection: 0)` during first layout pass
    /// (before business code applies first data snapshot). If the data source still has
    /// zero sections, UIKit can crash with:
    /// `NSInternalInconsistencyException`
    /// `request for number of items in section 0 when there are only 0 sections in the collection view`
    ///
    /// 某些自定义布局会在首帧布局阶段提前读取 `numberOfItems(inSection: 0)`。
    /// 如果此时业务层还没 apply 首个快照，dataSource 仍是 0 个 section，
    /// 就会触发上面的 `NSInternalInconsistencyException` 闪退。
    ///
    /// Call this early (e.g. right after creating the data source) to pre-create an empty section
    /// and avoid that first-frame crash.
    /// 建议在 dataSource 创建后立刻调用，先放一个空 section，避免首帧时序崩溃。
    func ensureSection(
        _ section: SectionIdentifierType,
        animatingDifferences: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        var current = snapshot()
        guard !current.sectionIdentifiers.contains(section) else {
            completion?()
            return
        }
        current.appendSections([section])
        apply(current, animatingDifferences: animatingDifferences, completion: completion)
    }
}

#endif
