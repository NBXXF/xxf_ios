//
//  ViewModelStoreOwner.swift
//  xxf_ios
//  viewModel 存储容器协议
//  Created by xxf on 8/14.
//
import Foundation

@MainActor
public protocol ViewModelStoreOwner: AnyObject {
    var viewModelStore: ViewModelStore { get }
}

private nonisolated(unsafe) var kViewModelStoreKey = 1024
public extension ViewModelStoreOwner where Self: NSObject {
    /// viewModel 存储器
    var viewModelStore: ViewModelStore {
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
