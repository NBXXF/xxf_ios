import Foundation

@available(iOS 13.0, *)
public protocol DiffableDataSourceAdapter<Section, Item> {
    associatedtype Section: Hashable
    associatedtype Item: Hashable

    func appendItems(_ items: [Item], to section: Section, animatingDifferences: Bool, completion: (() -> Void)?)
    func replaceItems(_ items: [Item], in section: Section, animatingDifferences: Bool, completion: (() -> Void)?)
    func deleteItems(where predicate: (Item) -> Bool, animatingDifferences: Bool, completion: (() -> Void)?)
    func moveItem(_ item: Item, before target: Item, animatingDifferences: Bool, completion: (() -> Void)?)
    func moveItem(_ item: Item, after target: Item, animatingDifferences: Bool, completion: (() -> Void)?)

    /// 获取指定 IndexPath 对应的 item
    func item(at indexPath: IndexPath) -> Item?

    /// 判断是否存在某个 section
    func hasSection(_ section: Section) -> Bool
}
