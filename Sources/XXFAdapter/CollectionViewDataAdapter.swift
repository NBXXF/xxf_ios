////
////  RxDiffableAdapter.swift
////  xxf_ios
////  适配器
////  Created by xxf on 2022/11/12.
////
//
// import UIKit
// import OrderedCollections
//
// @available(iOS 13.0, tvOS 13.0, *)
// @MainActor
// public protocol CollectionViewDataBindAdapter<Item>{
//    associatedtype Item
//    @MainActor @preconcurrency func collectionView(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item:Item)->UICollectionViewCell
// }
//
//
//// 一个基于 DiffableDataSource 的通用 Adapter（支持多 section / 单 section）
//// - Section: 必须 Hashable（可用 Void 表示单 section）
//// - Item: 必须 Hashable（通常基于 id 实现）
// @available(iOS 13.0, tvOS 13.0, *)
// @MainActor
// @preconcurrency open class CollectionViewDataAdapter<Section: Hashable& Sendable, Item: Hashable & Sendable>:UICollectionViewDiffableDataSource<Section, Item>,CollectionViewDataBindAdapter{
//
//    // MARK: - Private
//
//    /// 持有的 collectionView（弱引用，避免循环引用）
//    private weak var mCollectionView: UICollectionView?
//
//    /// 存储数据：OrderedDictionary 保持 section 顺序和 items
//    private var itemsOrdered: OrderedDictionary<Section, [Item]> = [:]
//
//
//    // MARK: - Init
//
//    /// 初始化 Adapter
//    /// - Parameters:
//    ///   - collectionView: 要绑定的 UICollectionView（Adapter 不会自动 register cell）
//    ///   业务自己实现#collectionView(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: Item)
//    public init(collectionView: UICollectionView){
//        super.init(collectionView: collectionView) { _, _, _ in UICollectionViewCell() }
//        self.mCollectionView = collectionView
//     }
//
//    // 重写父类方法，将 item 映射到 cell
//    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if let item = self.itemIdentifier(for: indexPath) {
//            return self.collectionView(collectionView: collectionView, cellForItemAt: indexPath, item: item)
//        }
//        return UICollectionViewCell()
//    }
//
//    // MARK: - Snapshot apply（直接主线程调用 apply）
//
//    /// 将当前 itemsOrdered 构建成 snapshot 并应用到 dataSource
//    /// - 注意：必须在主线程调用 `dataSource.apply`（苹果要求）
//    private func applySnapshot(animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
//        // 构造 snapshot
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
//        for (section, items) in itemsOrdered {
//            snapshot.appendSections([section])
//            // 如果某个 section 没有 items，会 append 空数组（安全）
//            snapshot.appendItems(items, toSection: section)
//        }
//
//        // 确保在主线程
//        self.apply(snapshot, animatingDifferences: animatingDifferences, completion: completion)
//    }
//
//    // MARK: - Public API: sections & items 操作
//
//    /// 显式设置 sections（按给定顺序），如果某些 section 在 itemsOrdered 里有旧数据会保留
//    public func setSections(_ sections: [Section]) {
//        var newOrdered: OrderedDictionary<Section, [Item]> = [:]
//        for s in sections {
//            newOrdered[s] = itemsOrdered[s] ?? []
//        }
//        itemsOrdered = newOrdered
//        applySnapshot()
//    }
//
//    /// 更新某个 section 的全部 items（若 section 不存在则追加到末尾）
//    /// - 注意：如果希望避免重复的 section，请保证 section 的 Hashable/等价性
//    public func updateItems(items: [Item], in section: Section, animated: Bool = true, completion: (() -> Void)? = nil) {
//        itemsOrdered[section] = items // 自动新增或覆盖
//        applySnapshot(animatingDifferences: animated, completion: completion)
//    }
//
//    /// 替换所有数据并按照传入顺序设置 sections
//    public func updateItems(all: [(Section, [Item])], animated: Bool = true, completion: (() -> Void)? = nil) {
//        var newOrdered: OrderedDictionary<Section, [Item]> = [:]
//        for (s, items) in all {
//            newOrdered[s] = items
//        }
//        itemsOrdered = newOrdered
//        applySnapshot(animatingDifferences: animated, completion: completion)
//    }
//
//    /// 向某个 section 追加一个 item（若 section 不存在则创建）
//    public func appendItem(item: Item, to section: Section, animated: Bool = true, completion: (() -> Void)? = nil) {
//        var arr = itemsOrdered[section] ?? []
//        arr.append(item)
//        itemsOrdered[section] = arr
//        applySnapshot(animatingDifferences: animated, completion: completion)
//    }
//
//    /// 根据谓词移除 items（遍历所有 section）
//    public func removeItems(where shouldRemove: (Item) -> Bool, animated: Bool = true, completion: (() -> Void)? = nil) {
//        var changed = false
//        for (section, before) in itemsOrdered {
//            let after = before.filter { !shouldRemove($0) }
//            if after.count != before.count {
//                changed = true
//                itemsOrdered[section] = after
//            }
//        }
//        if changed { applySnapshot(animatingDifferences: animated, completion: completion) }
//    }
//
//    /// 根据 indexPath 获取 Item（通过 dataSource 查询）
//    public func item(at indexPath: IndexPath) -> Item? {
//        return self.itemIdentifier(for: indexPath)
//    }
//
//    /// 获取底层 collectionView（只读）
//    public func collectionView() -> UICollectionView? {
//        return mCollectionView
//    }
//
//    /// 强制 apply（立即刷新）
//    public func forceApply(animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
//        applySnapshot(animatingDifferences: animatingDifferences, completion: completion)
//    }
// }
//
//
// extension CollectionViewDataAdapter{
//    public func collectionView(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: Item) -> UICollectionViewCell {
//        return UICollectionViewCell()
//    }
// }
//
//
// class S:CollectionViewDataAdapter<String,String>{
//    override func collectionView(collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, item: String) -> UICollectionViewCell {
//        return UICollectionViewCell()
//    }
// }
