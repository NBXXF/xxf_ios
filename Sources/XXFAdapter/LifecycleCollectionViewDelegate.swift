//
//  LifecycleCollectionViewDelegate.swift
//  xxf_ios
//
//  Created by xxf
//
#if canImport(UIKit)
import UIKit
open class LifecycleCollectionViewDelegate: NSObject, UICollectionViewDelegate
{
    open func collectionView(_ collectionView: UICollectionView,
                             willDisplay cell: UICollectionViewCell,
                             forItemAt indexPath: IndexPath)
    {
        (cell as? LifecycleCell)?.isDisplaying = true
    }

    open func collectionView(_ collectionView: UICollectionView,
                             didEndDisplaying cell: UICollectionViewCell,
                             forItemAt indexPath: IndexPath)
    {
        (cell as? LifecycleCell)?.isDisplaying = false
    }

    open func collectionView(_ collectionView: UICollectionView,
                             shouldSelectItemAt indexPath: IndexPath) -> Bool
    {
        guard let cell = collectionView.cellForItem(at: indexPath) as? LifecycleCell
        else
        {
            return true
        }
        return cell.cellShouldSelect(at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             shouldDeselectItemAt indexPath: IndexPath) -> Bool
    {
        guard let cell = collectionView.cellForItem(at: indexPath) as? LifecycleCell
        else
        {
            return true
        }
        return cell.cellShouldDeselect(at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             shouldHighlightItemAt indexPath: IndexPath) -> Bool
    {
        guard let cell = collectionView.cellForItem(at: indexPath) as? LifecycleCell
        else
        {
            return true
        }
        return cell.cellShouldHighlight(at: indexPath)
    }
}
#endif
