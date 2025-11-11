//
//  UICell+Auto.swift
//  xxf_ios
//  自动实现这个协议
//  Created by xxf
//

#if canImport(UIKit)
import UIKit

public extension UITableViewCell: Reusable {}
public extension UICollectionViewCell: Reusable {}
#endif
