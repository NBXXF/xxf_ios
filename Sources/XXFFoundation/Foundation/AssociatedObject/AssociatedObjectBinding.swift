//
//  test.swift
//  xxf_ios
//  进行关联对象绑定,常用于拓展类中,且内部高效
//  Created by xxf on 9/21.
//
import Foundation
import ObjectiveC

/**

 class MyClass: NSObject {
     @AssociatedObjectBinding("flag", default: false)
     var flag: Bool

     @AssociatedObjectBinding("name", default: "unknown")
     var name: String
 }

 */
@propertyWrapper
public struct AssociatedObjectBinding<Value> {
    private let key: String?
    private let defaultValue: Value

    public init(key: String? = nil, default defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public static subscript<EnclosingSelf: NSObject>(
        _enclosingInstance instance: EnclosingSelf,
        wrapped _: ReferenceWritableKeyPath<EnclosingSelf, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, AssociatedObjectBinding<Value>>
    ) -> Value {
        get {
            let wrapper = instance[keyPath: storageKeyPath]
            // 如果没有 key，用 KeyPath 的内存地址生成唯一字符串
            let key = wrapper.key ?? "AssociatedObject_\(ObjectIdentifier(storageKeyPath))"
            return instance.getAssociatedObject(key) ?? wrapper.defaultValue
        }
        set {
            let wrapper = instance[keyPath: storageKeyPath]
            let key = wrapper.key ?? "AssociatedObject_\(ObjectIdentifier(storageKeyPath))"
            instance.setAssociatedObject(newValue, forKey: key)
        }
    }

    public var wrappedValue: Value {
        get { fatalError("Should not be called directly") }
        set { fatalError("Should not be called directly") }
    }
}

// class MyClass: NSObject {
//    @AssociatedObjectBinding(default: false)
//    var flag: Bool
//
//    @AssociatedObjectBinding(default: "unknown")
//    var name: String
// }
