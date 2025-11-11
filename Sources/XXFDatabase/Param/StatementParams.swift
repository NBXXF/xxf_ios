//
//  StatementParams.swift
//  xxf_ios
//  约定Swift 编译器支持“字面量协议”
//  Created by xxf on /6/4.
//

/// 一个专门用于接收字面量或 StatementParams 的包装类型,解决sql "?"占位符替换
/// 可直接写数组和字典
public enum StatementParams {
    case array([Any?])
    case dict([String: Any?])

    // MARK: - 字面量初始化

    public init(arrayLiteral elements: Any?...) {
        self = .array(elements)
    }

    public init(dictionaryLiteral elements: (String, Any?)...) {
        self = .dict(Dictionary(uniqueKeysWithValues: elements))
    }
}

// 让它支持字面量协议
extension StatementParams: ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral {}
