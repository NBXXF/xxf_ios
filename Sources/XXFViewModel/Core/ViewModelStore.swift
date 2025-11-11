//
//  ViewModelStore.swift
//  xxf_ios
//  viewModel 缓存器
//  Created by xxf on 8/14.
//
import XXFFoundation

public final class ViewModelStore: @unchecked Sendable {
    private var store = ConcurrentDictionary<String, AnyObject>()

    func get<T: ViewModel>(_ type: T.Type) -> T {
        let key = String(describing: type)
        if let existing = store[key] as? T {
            return existing
        }
        // 使用无参 init
        let newVM = T()
        store[key] = newVM
        return newVM
    }

    func clear() {
        store.removeAll()
    }

    func clear<T: ViewModel>(_ type: T.Type) {
        let key = String(describing: type)
        store.remove(key)
    }
}
