//
//  UTType+Extension.swift
//  xxf_ios
//
//  Created by xxf on 6/14.
//

import UniformTypeIdentifiers

public extension UTType {
    /// 存文本字符串类型 .string文件
    static let strings = UTType(filenameExtension: "strings")

    /// 根据字符串判断是否是文件夹类型
    static func isFolder(_ identifier: String?) -> Bool {
        guard let id = identifier, let type = UTType(id) else { return false }
        return type.conforms(to: .folder)
    }

    /// 判断identifier 是不是指定类型的子级
    /// - Parameters:
    ///   - identifier: 文件类型标识
    ///   - to: 指定类型
    /// - Returns: 是否是对应类型
    static func isType(_ identifier: String?, conformingTo type: UTType) -> Bool {
        guard let id = identifier, let childType = UTType(id) else { return false }
        return childType.conforms(to: type)
    }

    /// 判断一个子类型标识符是否遵循当前 UTType
    func hasSubType(child identifier: String?) -> Bool {
        guard let id = identifier, let type = UTType(id) else { return false }
        return type.conforms(to: self) // <- 注意这里
    }

    /// 判断一个子类型标识符是否遵循当前 UTType
    func hasSubType(child type: UTType) -> Bool {
        return type.conforms(to: self) // <- 注意这里
    }
}
