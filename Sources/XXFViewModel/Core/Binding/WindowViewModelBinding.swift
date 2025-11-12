//
//  WindowViewModelBinding.swift
//  xxf_ios
//  window级别的viewModel装饰器
//  Created by xxf on 8/14.
//
#if os(macOS)
    import AppKit
    import Foundation

    // MARK: - Window 范围

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
    public final class WindowViewModelBinding<VM: ViewModel> {
        private let ownerProvider: () -> NSWindow?
        private lazy var value: VM = {
            guard let owner = ownerProvider() else {
                fatalError("Window is not available yet when accessing ViewModel.")
            }
            return ViewModelProvider(owner: owner).of(VM.self)
        }()

        public init(owner ownerProvider: @escaping () -> NSWindow?) {
            self.ownerProvider = ownerProvider
        }

        public var wrappedValue: VM {
            value
        }
    }
#endif
