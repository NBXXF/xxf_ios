//
//  UICollectionView+Demo.swift
//  xxf_ios
//
//  Created by xxf
//

// MARK: - UICollectionViewDelegate 全量常用方法（含 UIScrollViewDelegate）

//
// extension ViewController: UICollectionViewDelegate {
//
//    // MARK: - ⭐ 显示生命周期
//
//    // cell 即将显示（进入可见区域）
//    func collectionView(_ collectionView: UICollectionView,
//                        willDisplay cell: UICollectionViewCell,
//                        forItemAt indexPath: IndexPath) {
//        // 👉 用于：开始动画 / 自动播放 / 触发曝光
//    }
//
//    // cell 结束显示（离开屏幕）
//    func collectionView(_ collectionView: UICollectionView,
//                        didEndDisplaying cell: UICollectionViewCell,
//                        forItemAt indexPath: IndexPath) {
//        // 👉 用于：停止动画 / 暂停播放 / 清理资源
//    }
//
//
//    // MARK: - SupplementaryView（header/footer）
//
//    // header/footer 即将显示
//    func collectionView(_ collectionView: UICollectionView,
//                        willDisplaySupplementaryView view: UICollectionReusableView,
//                        forElementKind elementKind: String,
//                        at indexPath: IndexPath) {
//        // 👉 header/footer 出现
//    }
//
//    // header/footer 已消失
//    func collectionView(_ collectionView: UICollectionView,
//                        didEndDisplayingSupplementaryView view: UICollectionReusableView,
//                        forElementOfKind elementKind: String,
//                        at indexPath: IndexPath) {
//        // 👉 header/footer 离开屏幕
//    }
//
//
//    // MARK: - ⭐ 点击 / 选中
//
//    // 是否允许选中
//    func collectionView(_ collectionView: UICollectionView,
//                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    // 已选中（点击）
//    func collectionView(_ collectionView: UICollectionView,
//                        didSelectItemAt indexPath: IndexPath) {
//        // 👉 用户点击 cell
//    }
//
//    // 是否允许取消选中
//    func collectionView(_ collectionView: UICollectionView,
//                        shouldDeselectItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    // 已取消选中
//    func collectionView(_ collectionView: UICollectionView,
//                        didDeselectItemAt indexPath: IndexPath) {
//        // 👉 取消选中
//    }
//
//
//    // MARK: - ⭐ 高亮（按下状态）
//
//    // 是否允许高亮（手指按下）
//    func collectionView(_ collectionView: UICollectionView,
//                        shouldHighlightItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    // 已高亮（按下瞬间）
//    func collectionView(_ collectionView: UICollectionView,
//                        didHighlightItemAt indexPath: IndexPath) {
//        // 👉 可以做按压效果
//    }
//
//    // 取消高亮（松手）
//    func collectionView(_ collectionView: UICollectionView,
//                        didUnhighlightItemAt indexPath: IndexPath) {
//        // 👉 恢复状态
//    }
//
//
//    // MARK: - ⭐ Focus（tvOS / 键盘）
//
//    // 是否允许获取焦点
//    func collectionView(_ collectionView: UICollectionView,
//                        canFocusItemAt indexPath: IndexPath) -> Bool {
//        return true
//    }
//
//    // 是否允许焦点更新
//    func collectionView(_ collectionView: UICollectionView,
//                        shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
//        return true
//    }
//
//    // 焦点已经更新
//    func collectionView(_ collectionView: UICollectionView,
//                        didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
//                        with coordinator: UIFocusAnimationCoordinator) {
//        // 👉 焦点变化动画
//    }
//
//
//    // MARK: - ⭐ Context Menu（长按菜单 iOS13+）
//
//    // 提供菜单配置
//    func collectionView(_ collectionView: UICollectionView,
//                        contextMenuConfigurationForItemAt indexPath: IndexPath,
//                        point: CGPoint) -> UIContextMenuConfiguration? {
//        return nil
//    }
//
//    // 菜单即将显示
//    func collectionView(_ collectionView: UICollectionView,
//                        willDisplayContextMenu configuration: UIContextMenuConfiguration,
//                        animator: UIContextMenuInteractionAnimating?) {
//    }
//
//    // 菜单即将结束
//    func collectionView(_ collectionView: UICollectionView,
//                        willEndContextMenuInteraction configuration: UIContextMenuConfiguration,
//                        animator: UIContextMenuInteractionAnimating?) {
//    }
//
//
//    // MARK: - ⭐ 拖拽 Drag
//
//    // 开始拖拽
//    func collectionView(_ collectionView: UICollectionView,
//                        itemsForBeginning session: UIDragSession,
//                        at indexPath: IndexPath) -> [UIDragItem] {
//        return []
//    }
//
//
//    // MARK: - ⭐ Drop（接收拖拽）
//
//    // 是否可以处理 drop
//    func collectionView(_ collectionView: UICollectionView,
//                        canHandle session: UIDropSession) -> Bool {
//        return true
//    }
//
//    // drop 更新（决定 copy / move）
//    func collectionView(_ collectionView: UICollectionView,
//                        dropSessionDidUpdate session: UIDropSession,
//                        withDestinationIndexPath destinationIndexPath: IndexPath?)
//    -> UICollectionViewDropProposal {
//        return UICollectionViewDropProposal(operation: .copy)
//    }
//
//
//    // MARK: - ⭐ 多选（可选）
//
//    // 是否允许多选
//    func collectionView(_ collectionView: UICollectionView,
//                        shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//    // 多选开始
//    func collectionView(_ collectionView: UICollectionView,
//                        didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
//    }
//
//    // 多选结束
//    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
//    }
// }
//
//
//// MARK: - ⭐ UIScrollViewDelegate（UICollectionView 继承）
//
// extension ViewController: UIScrollViewDelegate {
//
//    // 滚动中（最常用）
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        // 👉 用于曝光统计 / 可见性计算 / 联动动画
//    }
//
//    // 即将开始拖拽
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//    }
//
//    // 已结束拖拽（可能继续减速）
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
//                                  willDecelerate decelerate: Bool) {
//    }
//
//    // 减速结束（完全停止）
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        // 👉 常用于：最终确定当前可见 cell
//    }
//
//    // 滚动动画结束（scrollToItem 等）
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//    }
//
//    // 即将开始减速
//    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//    }
//
//    // 滚动到顶部（点击状态栏）
//    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
//    }
//
//    // 是否允许滚动到顶部
//    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
//        return true
//    }
// }
