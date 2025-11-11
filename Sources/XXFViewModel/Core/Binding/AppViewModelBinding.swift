//
//  AppViewModelBinding.swift
//  xxf_ios
//  app级别的viewModel装饰器
//  Created by xxf on 2025/8/14.
//
#if os(macOS)
import AppKit
import Foundation

// MARK: - Application 范围

/**
 用法
 final class MyViewController: NSViewController {
     @VCViewModelBinding(owner: { [weak self] in self })
     var vcVM: MyViewControllerViewModel

      @AppViewModelBinding()
      var vcVM: MyViewControllerViewModel

      @WindowViewModelBinding(owner: { [weak self] in self?.view.window })
      var vcVM: MyViewControllerViewModel
 }
 */
@MainActor
@propertyWrapper
public final class AppViewModelBinding<VM: ViewModel> {
    private lazy var value: VM = ViewModelProvider(owner: NSApplication.shared).of(VM.self)

    public init() {}

    public var wrappedValue: VM {
        value
    }
}
#endif
