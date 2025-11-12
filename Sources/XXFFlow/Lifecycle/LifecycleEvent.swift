//
//  LifecycleEvent.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//

import Foundation
import ObjectiveC

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

public enum LifecycleEvent {
    case viewDidLoad
    case viewWillAppear
    case viewDidAppear
    case viewWillDisappear
    case viewDidDisappear
    case viewWillLayoutSubviews
    case viewDidLayoutSubviews
    case didMoveToParent
    case willMoveToParent
    case viewDeallocated

    var selector: Selector? {
        #if canImport(UIKit)
            switch self {
                case .viewDidLoad:
                return #selector(UIViewController.viewDidLoad)
                case .viewWillAppear:
                return #selector(UIViewController.viewWillAppear(_:))
                case .viewDidAppear:
                return #selector(UIViewController.viewDidAppear(_:))
                case .viewWillDisappear:
                return #selector(UIViewController.viewWillDisappear(_:))
                case .viewDidDisappear:
                return #selector(UIViewController.viewDidDisappear(_:))
                case .viewWillLayoutSubviews:
                return #selector(UIViewController.viewWillLayoutSubviews)
                case .viewDidLayoutSubviews:
                return #selector(UIViewController.viewDidLayoutSubviews)
                case .didMoveToParent:
                return #selector(UIViewController.didMove(toParent:))
                case .willMoveToParent:
                return #selector(UIViewController.willMove(toParent:))
                case .viewDeallocated: return nil
            }
        #elseif canImport(AppKit)
            // macOS 下 NSViewController 没有完全对应的事件，需要根据实际用法调整
            switch self {
                case .viewDidLoad:
                return #selector(NSViewController.viewDidLoad)
                case .viewWillAppear:
                return #selector(NSViewController.viewWillAppear)
                case .viewDidAppear:
                return #selector(NSViewController.viewDidAppear)
                case .viewWillDisappear:
                return #selector(NSViewController.viewWillDisappear)
                case .viewDidDisappear:
                return #selector(NSViewController.viewDidDisappear)
                case .viewWillLayoutSubviews:
                return #selector(NSViewController.viewWillLayout) // 近似
                case .viewDidLayoutSubviews:
                return #selector(NSViewController.viewDidLayout) // 近似
                case .didMoveToParent, .willMoveToParent:
                // macOS 没有 parentViewController 的移动事件
                fatalError("Not supported on AppKit")
                case .viewDeallocated: return nil
            }
        #endif
    }
}
