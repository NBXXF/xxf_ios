//
//  Color+Platform.swift
//  xxf_ios
//
//  Created by xxf on 2022/7/11.
//

#if canImport(UIKit)
import UIKit
public typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias PlatformColor = NSColor
#endif
