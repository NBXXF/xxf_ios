//
//  AssociatedObject.swift
//  xxf_ios
//  简化关联对象的访问,主要是key 可以不是指针
//  Created by xxf on 6/12.
//

import Foundation
import ObjectiveC.runtime

public extension NSObject {
    private nonisolated(unsafe) static var associatedDictionaryKey: UInt8 = 0
    private static let associatedDictionaryLock = NSLock()

    private var innerAssociatedDictionary: NSMutableDictionary {
        get {
            if let dict = objc_getAssociatedObject(self, &Self.associatedDictionaryKey) as? NSMutableDictionary {
                return dict
            } else {
                let dict = NSMutableDictionary()
                objc_setAssociatedObject(self, &Self.associatedDictionaryKey, dict, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return dict
            }
        }
        set {
            objc_setAssociatedObject(self, &Self.associatedDictionaryKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func setAssociatedObject(_ object: Any?, forKey key: String) {
        Self.associatedDictionaryLock.lock()
        defer { Self.associatedDictionaryLock.unlock() }
        if let obj = object {
            innerAssociatedDictionary[key] = obj
        } else {
            innerAssociatedDictionary.removeObject(forKey: key)
        }
    }

    func getAssociatedObject<T>(_ key: String) -> T? {
        Self.associatedDictionaryLock.lock()
        defer { Self.associatedDictionaryLock.unlock() }
        return innerAssociatedDictionary[key] as? T
    }
}
