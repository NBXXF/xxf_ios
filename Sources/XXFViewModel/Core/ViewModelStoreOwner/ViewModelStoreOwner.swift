//
//  ViewModelStoreOwner.swift
//  xxf_ios
//  viewModel 存储容器协议
//  Created by xxf on 8/14.
//

@MainActor
public protocol ViewModelStoreOwner: AnyObject {
    var viewModelStore: ViewModelStore { get }
}
