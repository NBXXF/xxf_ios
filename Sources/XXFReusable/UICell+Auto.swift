//
//  UICell+Auto.swift
//  xxf_ios
//  自动实现这个协议
//  Created by xxf
//

#if canImport(UIKit)
    import UIKit

    extension UITableViewCell: Reusable {}
    extension UICollectionViewCell: Reusable {}
#endif
