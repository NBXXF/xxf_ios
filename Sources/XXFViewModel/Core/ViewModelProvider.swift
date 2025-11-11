//
//  ViewModelProvider.swift
//  xxf_ios
//  获取viewModel（在ViewModelStoreOwner 上面获取viewModel）
//  Created by xxf on 8/14.
//

/**

 前提:
 import XXFAppkit 或者XXFViewModel
 MyViewmodel 添加ViewModel协议（不需要实现任何东西）

 用法一:  app 全局
 let appProvider = ViewModelProvider(owner: NSApplication.shared)
 let myVM= appProvider.of(MyAppViewModel.self)

 用法二:  window 级别
 let windowProvider = ViewModelProvider(owner: self.window)
 let myVM = windowProvider.of(MyViewModel.self)

 用法三 : viewController 级别
 let vcViewModelProvider = ViewModelProvider(owner: self)
 let myVM = vcViewModelProvider.of(MyViewModel.self)

 方法四： 用属性装饰器直接初始化,后期考虑用宏优化参数
 final class MyViewController: NSViewController {
     @VCViewModelBinding(owner: { [weak self] in self })
     var vcVM: MyViewControllerViewModel

      @AppViewModelBinding()
      var vcVM: MyViewControllerViewModel

      @WindowViewModelBinding(owner: { [weak self] in self?.view.window })
      var vcVM: MyViewControllerViewModel
 }
 */
public final class ViewModelProvider: @unchecked Sendable {
    let owner: ViewModelStoreOwner

    public init(owner: ViewModelStoreOwner) { self.owner = owner }

    @MainActor
    public func of<T: ViewModel>(_ type: T.Type) -> T {
        return owner.viewModelStore.get(type)
    }

    /// 清除指定类型的 ViewModel
    /// - Parameter type: 需要清除的 ViewModel 类型
    @MainActor
    public func clear<T: ViewModel>(_ type: T.Type) {
        owner.viewModelStore.clear(type)
    }
}
