//
//  UITableViewDiffableDataSource+Extensions.swift
//  xxf_ios
//
//  Created by xxf on 2021/11/12.
//

import UIKit

@available(iOS 13.0, *)
@MainActor
extension UITableViewDiffableDataSource: @preconcurrency DiffableDataSourceAdapter {
    // MARK: - 🔹 添加 / 更新

    /// 向指定 section 追加 items 并立即应用 snapshot
    ///
    /// 常用于分页加载、动态追加数据等场景。
    ///
    /// ```swift
    /// dataSource.appendItems(newItems, to: .main)
    /// ```
    public func appendItems(_ items: [ItemIdentifierType],
                            to section: SectionIdentifierType,
                            animatingDifferences: Bool = true,
                            completion: (() -> Void)? = nil)
    {
        guard !items.isEmpty else {
            completion?()
            return
        }

        var snapshot = self.snapshot()
        if !snapshot.sectionIdentifiers.contains(section) {
            snapshot.appendSections([section])
        }
        snapshot.appendItems(items, toSection: section)
        applyOnMain(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }

    /// 重新加载多个 section 的所有数据（全量刷新）
    ///
    /// ```swift
    /// dataSource.reloadSections([
    ///   (.main, items),
    ///   (.favorite, favorites)
    /// ])
    /// ```
    public func reloadSections(_ sections: [(SectionIdentifierType, [ItemIdentifierType])],
                               animatingDifferences: Bool = true,
                               completion: (() -> Void)? = nil)
    {
        var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
        for (section, items) in sections {
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
        applyOnMain(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }

    /// 替换指定 section 内的所有 items
    ///
    /// ```swift
    /// dataSource.replaceItems(newItems, in: .main)
    /// ```
    public func replaceItems(_ items: [ItemIdentifierType],
                             in section: SectionIdentifierType,
                             animatingDifferences: Bool = true,
                             completion: (() -> Void)? = nil)
    {
        var snapshot = self.snapshot()
        if !snapshot.sectionIdentifiers.contains(section) {
            snapshot.appendSections([section])
        }

        let oldItems = snapshot.itemIdentifiers(inSection: section)
        if !oldItems.isEmpty {
            snapshot.deleteItems(oldItems)
        }

        snapshot.appendItems(items, toSection: section)
        applyOnMain(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }

    // MARK: - 🔹 删除

    /// 删除满足条件的 items（跨 section）
    ///
    /// ```swift
    /// dataSource.deleteItems { $0.id == targetId }
    /// ```
    public func deleteItems(where predicate: (ItemIdentifierType) -> Bool,
                            animatingDifferences: Bool = true,
                            completion: (() -> Void)? = nil)
    {
        var snapshot = self.snapshot()
        var itemsToRemove: [ItemIdentifierType] = []

        for section in snapshot.sectionIdentifiers {
            let sectionItems = snapshot.itemIdentifiers(inSection: section)
            itemsToRemove.append(contentsOf: sectionItems.filter(predicate))
        }

        guard !itemsToRemove.isEmpty else {
            completion?()
            return
        }

        snapshot.deleteItems(itemsToRemove)
        applyOnMain(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }

    // MARK: - 🔹 移动

    /// 将指定 item 移动到目标 item 之前
    ///
    /// ```swift
    /// dataSource.moveItem(itemA, before: itemB)
    /// ```
    public func moveItem(_ item: ItemIdentifierType,
                         before target: ItemIdentifierType,
                         animatingDifferences: Bool = true,
                         completion: (() -> Void)? = nil)
    {
        var snapshot = self.snapshot()
        guard snapshot.itemIdentifiers.contains(item),
              snapshot.itemIdentifiers.contains(target),
              item != target
        else {
            completion?()
            return
        }

        snapshot.moveItem(item, beforeItem: target)
        applyOnMain(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }

    /// 将指定 item 移动到目标 item 之后
    ///
    /// ```swift
    /// dataSource.moveItem(itemC, after: itemD)
    /// ```
    public func moveItem(_ item: ItemIdentifierType,
                         after target: ItemIdentifierType,
                         animatingDifferences: Bool = true,
                         completion: (() -> Void)? = nil)
    {
        var snapshot = self.snapshot()
        guard snapshot.itemIdentifiers.contains(item),
              snapshot.itemIdentifiers.contains(target),
              item != target
        else {
            completion?()
            return
        }

        snapshot.moveItem(item, afterItem: target)
        applyOnMain(snapshot, animatingDifferences: animatingDifferences, completion: completion)
    }

    // MARK: - 🔹 辅助

    /// 获取指定 IndexPath 对应的 item
    public func item(at indexPath: IndexPath) -> ItemIdentifierType? {
        return itemIdentifier(for: indexPath)
    }

    /// 判断是否存在某个 section
    public func hasSection(_ section: SectionIdentifierType) -> Bool {
        return snapshot().sectionIdentifiers.contains(section)
    }

    /// 保证在主线程安全地执行 apply
    private func applyOnMain(_ snapshot: NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>,
                             animatingDifferences: Bool,
                             completion: (() -> Void)?)
    {
        if Thread.isMainThread {
            apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
        } else {
            DispatchQueue.main.async {
                self.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
            }
        }
    }
}
