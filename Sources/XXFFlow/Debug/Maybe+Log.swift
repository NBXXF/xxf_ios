//
//  Maybe+Log.swift
//  xxf_ios
//
//  Created by xxf on 6/30.
//
import RxSwift

// MARK: - Maybe

public extension PrimitiveSequence where Trait == MaybeTrait {
    /// 取代官方的debug,官方的是print打印的,且没办法定义日志级别以及区分debug/release等等
    /// - Parameters:
    ///   - identifier: 唯一标识,不加则自动组装file+line+function
    ///   - types: 打印哪些事件
    ///   - file: 自动采集文件名
    ///   - line: 自动采集代码行数
    ///   - function: 自动采集调用方法
    /// - Returns: 原始类型
    func debugPlus(_ identifier: String? = nil,
                   trimOutput: Bool = false,
                   types: [LogEventTypeTag] = LogEventTypeTag.allCases,
                   file: String = #file,
                   function: String = #function,
                   line: Int = #line,
                   _ message: LogEventHandler<Element>? = nil) -> Maybe<Element>
    {
        let loggedObservable = asObservable().logEvents(identifier,
                                                        trimOutput: trimOutput,
                                                        types: types,
                                                        file: file,
                                                        function: function, line: line,
                                                        message)
        return loggedObservable.asMaybe()
    }

    /// 取代官方的debug,官方的是print打印的,且没办法定义日志级别以及区分debug/release等等
    /// - Parameters:
    ///   - identifier: 唯一标识,不加则自动组装file+line+function
    ///   - types: 打印哪些事件
    ///   - file: 自动采集文件名
    ///   - line: 自动采集代码行数
    ///   - function: 自动采集调用方法
    /// - Returns: 原始类型
    func logEvents(_ identifier: String? = nil,
                   trimOutput: Bool = false,
                   types: [LogEventTypeTag] = LogEventTypeTag.allCases,
                   file: String = #file,
                   function: String = #function,
                   line: Int = #line,
                   _ message: LogEventHandler<Element>? = nil) -> Maybe<Element>
    {
        return debugPlus(identifier,
                         trimOutput: trimOutput,
                         types: types,
                         file: file,
                         function: function, line: line,
                         message)
    }
}
