//
//  ViewModelStoreOwner+Window.swift
//  xxf_ios
//  APP级别的viewModel 存储器
//  Created by xxf on 8/14.
//
import Foundation
#if os(macOS)
    import AppKit

    extension NSApplication: ViewModelStoreOwner {}

#elseif canImport(UIKit)
    import UIKit

    extension UIApplication: ViewModelStoreOwner {}
#endif
