//
//  ViewModelStoreOwner+ViewController.swift
//  xxf_ios
//  ViewController级别的viewModel 存储器
//  Created by xxf on 8/14.
//

import Foundation
#if os(macOS)
    import AppKit

    extension NSViewController: ViewModelStoreOwner {}

#elseif canImport(UIKit)
    import UIKit

    extension UIViewController: ViewModelStoreOwner {}
#endif
