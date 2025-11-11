//
//  VCViewModelBinding.swift
//  xxf_ios
//  vc级别的viewModel装饰器
//  Created by xxf on 2025/8/14.
//

import AppKit
import Foundation

// MARK: - ViewController 范围

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
public final class VCViewModelBinding<VM: ViewModel> {
    private let ownerProvider: () -> NSViewController?
    private lazy var value: VM = {
        guard let owner = ownerProvider() else {
            fatalError("Owner not available yet.")
        }
        return ViewModelProvider(owner: owner).of(VM.self)
    }()

    public init(owner ownerProvider: @escaping () -> NSViewController?) {
        self.ownerProvider = ownerProvider
    }

    public var wrappedValue: VM { value }
}
