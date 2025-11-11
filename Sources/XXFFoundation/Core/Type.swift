//
//  Type.swift
//  xxf_ios
//  支持类型获取
//  Created by xxfon /6/4.
//

import ObjectiveC

// public protocol TypeProtocol {
//    static var type: Self.Type { get }
//    static var typeName: String { get }
//
//    var type: Self.Type { get }
//    var typeName: String { get }
// }
//
// public extension TypeProtocol {
//    static var type: Self.Type {
//        return Self.self
//    }
//
//    static var typeName: String {
//        String(describing: Self.self)
//    }
//
//    var type: Self.Type {
//        return Swift.type(of: self)
//    }
//
//    var typeName: String {
//        String(describing: Swift.type(of: self))
//    }
// }
//
//// MARK: - 基础类型拓展
//
// extension NSObject: TypeProtocol {}
// extension String: TypeProtocol {}
// extension Int: TypeProtocol {}
// extension Double: TypeProtocol {}
// extension Bool: TypeProtocol {}
// extension Float: TypeProtocol {}
//
//// MARK: - 泛型容器类型
//
// extension Array: TypeProtocol {}
// extension Dictionary: TypeProtocol {}
// extension Set: TypeProtocol {}
// extension Optional: TypeProtocol {}
