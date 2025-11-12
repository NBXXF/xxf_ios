//
//  ViewModelStoreOwner+Window.swift
//  xxf_ios
//  window级别的viewModel 存储器
//  Created by xxf on 8/14.
//
import Foundation
#if os(macOS)
    import AppKit

    extension NSWindow: ViewModelStoreOwner {}

#elseif canImport(UIKit)
    import UIKit

    extension UIWindow: ViewModelStoreOwner {}
#endif
