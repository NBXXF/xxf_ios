//
//  CenteringCollectionViewLayout.swift
//  xxf_ios
//  能水平/垂直居中的的UICollectionViewLayout
//  Created by xxf on 5/11.
//
#if canImport(UIKit)
import UIKit

/// A single-line collection view layout that centers content when it does not fill the viewport.
/// Supports both horizontal and vertical primary axis.
public final class CenteringCollectionViewLayout: UICollectionViewLayout {
    public enum Axis {
        case horizontal
        case vertical
    }

    /// Primary axis used to place items.
    public var axis: Axis = .horizontal {
        didSet {
            guard oldValue != axis else { return }
            invalidateLayout()
        }
    }

    /// Item spacing along the primary axis.
    public var interItemSpacing: CGFloat = 0 {
        didSet {
            guard oldValue != interItemSpacing else { return }
            invalidateLayout()
        }
    }

    /// Insets applied before centering calculation and content size.
    public var contentInsets: UIEdgeInsets = .zero {
        didSet {
            guard oldValue != contentInsets else { return }
            invalidateLayout()
        }
    }

    /// Convenience sizes for single-section usage.
    /// If `itemSizeProvider` is set, it takes precedence.
    public var itemSizes: [CGSize] = [] {
        didSet {
            guard oldValue != itemSizes else { return }
            invalidateLayout()
        }
    }

    /// Optional provider for dynamic item sizes.
    /// If nil, falls back to `itemSizes` by flattened item index.
    public var itemSizeProvider: ((IndexPath) -> CGSize)? {
        didSet {
            invalidateLayout()
        }
    }

    private var cachedAttributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var contentSize: CGSize = .zero

    public override init() {
        super.init()
    }

    override func prepare() {
        super.prepare()
        guard let collectionView else { return }

        cachedAttributes.removeAll(keepingCapacity: true)

        let indexPaths = allIndexPaths(in: collectionView)
        let boundsSize = collectionView.bounds.size
        guard !indexPaths.isEmpty else {
            contentSize = boundsSize
            return
        }

        let spacing = max(0, interItemSpacing)
        let maxWidth = max(0, boundsSize.width)
        let maxHeight = max(0, boundsSize.height)

        let primaryAvailable: CGFloat
        let secondaryAvailable: CGFloat

        switch axis {
        case .horizontal:
            primaryAvailable = max(0, maxWidth - contentInsets.left - contentInsets.right)
            secondaryAvailable = max(0, maxHeight - contentInsets.top - contentInsets.bottom)
        case .vertical:
            primaryAvailable = max(0, maxHeight - contentInsets.top - contentInsets.bottom)
            secondaryAvailable = max(0, maxWidth - contentInsets.left - contentInsets.right)
        }

        var resolvedSizes: [CGSize] = []
        resolvedSizes.reserveCapacity(indexPaths.count)

        for (flatIndex, indexPath) in indexPaths.enumerated() {
            let size = resolvedSize(at: indexPath, flatIndex: flatIndex)
            resolvedSizes.append(CGSize(width: max(0, size.width), height: max(0, size.height)))
        }

        let totalPrimaryItemsLength: CGFloat = resolvedSizes.reduce(0) { partialResult, size in
            switch axis {
            case .horizontal:
                partialResult + size.width
            case .vertical:
                partialResult + size.height
            }
        }

        let totalSpacing = spacing * CGFloat(max(0, resolvedSizes.count - 1))
        let primaryContentLength = totalPrimaryItemsLength + totalSpacing

        let primaryStart: CGFloat
        switch axis {
        case .horizontal:
            primaryStart = contentInsets.left + (primaryContentLength < primaryAvailable ? (primaryAvailable - primaryContentLength) * 0.5 : 0)
        case .vertical:
            primaryStart = contentInsets.top + (primaryContentLength < primaryAvailable ? (primaryAvailable - primaryContentLength) * 0.5 : 0)
        }

        var currentPrimary = primaryStart
        for (index, indexPath) in indexPaths.enumerated() {
            let size = resolvedSizes[index]
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)

            let frame: CGRect
            switch axis {
            case .horizontal:
                let originY = contentInsets.top + max(0, (secondaryAvailable - size.height) * 0.5)
                frame = CGRect(x: currentPrimary, y: originY, width: size.width, height: size.height)
                currentPrimary += size.width
            case .vertical:
                let originX = contentInsets.left + max(0, (secondaryAvailable - size.width) * 0.5)
                frame = CGRect(x: originX, y: currentPrimary, width: size.width, height: size.height)
                currentPrimary += size.height
            }

            attributes.frame = frame.integral
            cachedAttributes[indexPath] = attributes

            if index < indexPaths.count - 1 {
                currentPrimary += spacing
            }
        }

        switch axis {
        case .horizontal:
            let neededWidth = contentInsets.left + primaryContentLength + contentInsets.right
            contentSize = CGSize(width: max(maxWidth, neededWidth), height: maxHeight)
        case .vertical:
            let neededHeight = contentInsets.top + primaryContentLength + contentInsets.bottom
            contentSize = CGSize(width: maxWidth, height: max(maxHeight, neededHeight))
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cachedAttributes
            .values
            .filter { $0.frame.intersects(rect) }
            .sorted { lhs, rhs in
                if lhs.indexPath.section == rhs.indexPath.section {
                    return lhs.indexPath.item < rhs.indexPath.item
                }
                return lhs.indexPath.section < rhs.indexPath.section
            }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cachedAttributes[indexPath]
    }

    override var collectionViewContentSize: CGSize {
        contentSize
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView else { return true }
        return collectionView.bounds.size != newBounds.size
    }

    override func invalidateLayout() {
        cachedAttributes.removeAll(keepingCapacity: true)
        super.invalidateLayout()
    }

    private func allIndexPaths(in collectionView: UICollectionView) -> [IndexPath] {
        let sectionCount = collectionView.numberOfSections
        guard sectionCount > 0 else { return [] }

        var indexPaths: [IndexPath] = []
        for section in 0..<sectionCount {
            let itemCount = collectionView.numberOfItems(inSection: section)
            guard itemCount > 0 else { continue }
            for item in 0..<itemCount {
                indexPaths.append(IndexPath(item: item, section: section))
            }
        }
        return indexPaths
    }

    private func resolvedSize(at indexPath: IndexPath, flatIndex: Int) -> CGSize {
        if let itemSizeProvider {
            return itemSizeProvider(indexPath)
        }

        if flatIndex < itemSizes.count {
            return itemSizes[flatIndex]
        }

        return .zero
    }
}
#endif
