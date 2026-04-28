//
//  LifecycleCell.swift
//  xxf_ios
//
//  Created by xxf on 2021/4/16.
//

#if canImport(UIKit)
import UIKit

// MARK: - 官方能力 vs 本协议补充对照表

//
// | UICollectionViewDelegate 事件 | UICollectionViewCell 官方自带 | 本协议补充         |
// |------------------------------|------------------------------|------------------|
// | willDisplay / didEndDisplaying | ❌ 无官方字段/方法              | ✅ isDisplaying   |
// | didSelectItemAt               | ✅ isSelected (可覆写 setSelected) | —                |
// | didDeselectItemAt             | ✅ isSelected (可覆写 setSelected) | —                |
// | didHighlightItemAt            | ✅ isHighlighted (可覆写 setHighlighted) | —          |
// | didUnhighlightItemAt          | ✅ isHighlighted (可覆写 setHighlighted) | —          |
// | shouldSelectItemAt            | ❌ 无官方方法                   | ✅ cellShouldSelect |
// | shouldDeselectItemAt          | ❌ 无官方方法                   | ✅ cellShouldDeselect |
// | shouldHighlightItemAt         | ❌ 无官方方法                   | ✅ cellShouldHighlight |
//
// 因此，本协议只保留 cell 自身无法直接感知的事件，
// 选中/高亮的“后置状态变化”请直接覆写官方属性。

// MARK: - UICollectionViewCell 无法自行感知的事件桥接协议

@MainActor
public protocol LifecycleCell: AnyObject {
    /// cell 是否正在显示
    /// 需要业务自己回调或者使用LifecycleCollectionViewDelegate
    /// - 说明:
    ///   该字段由 `UICollectionViewDelegate` 的
    ///   `collectionView(_:willDisplay:forItemAt:)` 和
    ///   `collectionView(_:didEndDisplaying:forItemAt:)` 来维护。
    ///   cell 可通过覆写 `didSet` 观察该属性，执行开始/停止动画、播放/暂停视频等逻辑。
    var isDisplaying: Bool { get set }

    /// 询问：是否允许选中
    ///
    /// - 说明:
    ///   这个事件来自 `UICollectionViewDelegate` 的
    ///   `collectionView(_:shouldSelectItemAt:)`
    ///
    ///   `UICollectionViewCell` 虽然可以覆写 `isSelected` 的变化，
    ///   但那是在“已经选中之后”才会收到。
    ///   对于“选中之前要不要允许”这种前置决策，cell 本身无权直接参与，
    ///   只能通过 delegate 转发。
    func cellShouldSelect(at indexPath: IndexPath) -> Bool

    /// 询问：是否允许取消选中
    ///
    /// - 说明:
    ///   这个事件来自 `UICollectionViewDelegate` 的
    ///   `collectionView(_:shouldDeselectItemAt:)`
    func cellShouldDeselect(at indexPath: IndexPath) -> Bool

    /// 询问：是否允许高亮
    ///
    /// - 说明:
    ///   这个事件来自 `UICollectionViewDelegate` 的
    ///   `collectionView(_:shouldHighlightItemAt:)`
    func cellShouldHighlight(at indexPath: IndexPath) -> Bool
}

// MARK: - 默认实现

public extension LifecycleCell {
    func cellShouldSelect(at indexPath: IndexPath) -> Bool { true }
    func cellShouldDeselect(at indexPath: IndexPath) -> Bool { true }
    func cellShouldHighlight(at indexPath: IndexPath) -> Bool { true }
}

// MARK: - 调用示例（由外部 Delegate 维护 isDisplaying）

//
// extension ViewController: UICollectionViewDelegate {
//
//     func collectionView(_ collectionView: UICollectionView,
//                         willDisplay cell: UICollectionViewCell,
//                         forItemAt indexPath: IndexPath) {
//         (cell as? LifecycleCell)?.isDisplaying = true
//     }
//
//     func collectionView(_ collectionView: UICollectionView,
//                         didEndDisplaying cell: UICollectionViewCell,
//                         forItemAt indexPath: IndexPath) {
//         (cell as? LifecycleCell)?.isDisplaying = false
//     }
//
//     func collectionView(_ collectionView: UICollectionView,
//                         shouldSelectItemAt indexPath: IndexPath) -> Bool {
//         guard let cell = collectionView.cellForItem(at: indexPath) as? LifecycleCell else {
//             return true
//         }
//         return cell.cellShouldSelect(at: indexPath)
//     }
//
//     func collectionView(_ collectionView: UICollectionView,
//                         shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//         guard let cell = collectionView.cellForItem(at: indexPath) as? LifecycleCell else {
//             return true
//         }
//         return cell.cellShouldDeselect(at: indexPath)
//     }
//
//     func collectionView(_ collectionView: UICollectionView,
//                         shouldHighlightItemAt indexPath: IndexPath) -> Bool {
//         guard let cell = collectionView.cellForItem(at: indexPath) as? LifecycleCell else {
//             return true
//         }
//         return cell.cellShouldHighlight(at: indexPath)
//     }
//
//     // 选中/高亮的后置状态变化直接由 cell 内部覆写官方属性处理，无需 delegate 转发：
//     // override var isSelected: Bool { didSet { ... } }
//     // override var isHighlighted: Bool { didSet { ... } }
// }
//
// MARK: - Cell 内部使用示例

//
// final class MyCell: UICollectionViewCell, LifecycleCell {
//     var isDisplaying: Bool = false {
//         didSet {
//             if isDisplaying {
//                 player?.play()
//             } else {
//                 player?.pause()
//             }
//         }
//     }
//
//     override var isSelected: Bool {
//         didSet { contentView.backgroundColor = isSelected ? .systemBlue : .white }
//     }
//
//     override var isHighlighted: Bool {
//         didSet { contentView.alpha = isHighlighted ? 0.8 : 1.0 }
//     }
//
//     func cellShouldSelect(at indexPath: IndexPath) -> Bool {
//         return indexPath.row > 0
//     }
// }
//
#endif
