//
//  AssociatedObject.swift
//  xxf_ios
//  简化关联对象的访问,主要是key 可以不是指针,且复用同一个字典,基本和普通属性性能持平
//  Created by xxf on 6/12.
//

import Foundation
import ObjectiveC.runtime

public extension NSObject {
    private nonisolated(unsafe) static var associatedDictionaryKey: UInt8 = 0

    // 用并发安全字典代替 NSMutableDictionary
    private var innerAssociatedDictionary: ConcurrentDictionary<String, Any> {
        get {
            if let dict = objc_getAssociatedObject(self, &Self.associatedDictionaryKey) as? ConcurrentDictionary<String, Any> {
                return dict
            } else {
                let dict = ConcurrentDictionary<String, Any>()
                objc_setAssociatedObject(self, &Self.associatedDictionaryKey, dict, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return dict
            }
        }
        set {
            objc_setAssociatedObject(self, &Self.associatedDictionaryKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// 建议使用属性装饰器  @AssociatedObjectBinding("flag", default: false) 这种方式
    /// - Parameters:
    ///   - object: 对象
    ///   - key: key
    func setAssociatedObject(_ object: Any?, forKey key: String) {
        if let obj = object {
            innerAssociatedDictionary[key] = obj
        } else {
            innerAssociatedDictionary.remove(key)
        }
    }

    /// 建议使用属性装饰器  @AssociatedObjectBinding("flag", default: false) 这种方式
    /// - Parameters:
    ///   - key: key
    func getAssociatedObject<T>(_ key: String) -> T? {
        return innerAssociatedDictionary[key] as? T
    }
}
