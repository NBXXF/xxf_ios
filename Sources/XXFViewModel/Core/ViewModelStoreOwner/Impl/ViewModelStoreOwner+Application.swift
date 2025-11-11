//
//  ViewModelStoreOwner+Window.swift
//  xxf_ios
//  APP级别的viewModel 存储器
//  Created by xxf on 8/14.
//
#if os(macOS)
import AppKit
import Foundation

private nonisolated(unsafe) var kViewModelStoreKey = 1024

extension NSApplication: ViewModelStoreOwner {
    /// APP级别的viewModel 存储器
    public var viewModelStore: ViewModelStore {
        get {
            if let store = objc_getAssociatedObject(self, &kViewModelStoreKey) as? ViewModelStore {
                return store
            }
            let store = ViewModelStore()
            objc_setAssociatedObject(self, &kViewModelStoreKey, store, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return store
        }
        set {
            objc_setAssociatedObject(self, &kViewModelStoreKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
#endif
