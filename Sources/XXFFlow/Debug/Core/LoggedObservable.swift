//
//  LoggedObservable.swift
//  xxf_ios
//  用于日志记录跟踪
//  Created by xxf on 6/30.
//
import Foundation
import RxSwift

public typealias LogEventHandler<Element> = (_ logEvent: LogEventType<Element>,
                                             _ identifier: String?,
                                             _ trimOutput: Bool,
                                             _ file: String,
                                             _ function: String,
                                             _ line: Int) -> Void

public final class LoggedObservable<Source: ObservableType>: ObservableType {
    public typealias Element = Source.Element

    fileprivate let identifier: String
    fileprivate let trimOutput: Bool
    fileprivate let logEventTypes: Set<LogEventTypeTag>
    fileprivate let file: String
    fileprivate let function: String
    fileprivate let line: Int
    private let source: Source
    private let message: LogEventHandler<Element>

    init(source: Source,
         identifier: String?,
         trimOutput: Bool,
         logEventTypes: [LogEventTypeTag],
         file: String,
         function: String,
         line: Int,
         message: @escaping LogEventHandler<Element>)
    {
        self.source = source
        if let identifier = identifier {
            self.identifier = identifier
        } else {
            let trimmedFile: String = Self.trimmedFile(file: file)
            self.identifier = "\(trimmedFile):\(line) (\(function))"
        }
        self.trimOutput = trimOutput
        self.logEventTypes = logEventTypes.toSet()
        self.file = file
        self.function = function
        self.line = line
        self.message = message
    }

    /// 获取最后一个文件名
    /// - Parameter file: 原文件
    /// - Returns: 简化文件名
    private static func trimmedFile(file: String) -> String {
        let trimmedFile: String
        if let lastIndex = file.lastIndex(of: "/") {
            trimmedFile = String(file[file.index(after: lastIndex) ..< file.endIndex])
        } else {
            trimmedFile = file
        }
        return trimmedFile
    }

    public func subscribe<Observer>(_ observer: Observer) -> any RxSwift.Disposable where Observer: RxSwift.ObserverType, Element == Observer.Element {
        return source.do(
            onNext: logEventTypes.contains(.next)
                ? { self.message(.next($0), self.identifier, self.trimOutput, self.file, self.function, self.line) }
                : nil,
            onError: logEventTypes.contains(.error)
                ? { self.message(.error($0), self.identifier, self.trimOutput, self.file, self.function, self.line) }
                : nil,
            onCompleted: logEventTypes.contains(.completed)
                ? { self.message(.completed, self.identifier, self.trimOutput, self.file, self.function, self.line) }
                : nil,
            onSubscribe: logEventTypes.contains(.subscribed)
                ? { self.message(.subscribed, self.identifier, self.trimOutput, self.file, self.function, self.line) }
                : nil,
            onDispose: logEventTypes.contains(.disposed)
                ? { self.message(.disposed, self.identifier, self.trimOutput, self.file, self.function, self.line) }
                : nil
        ).subscribe(observer)
    }
}
