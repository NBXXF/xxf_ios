//
//  Single+XXFTiming.swift
//  xxf_ios
//
//  Created by xxf on /6/4.
//
import Foundation
import RxSwift
import XXFFoundation

public extension ObservableType {
    /// 测量当前步骤的耗时
    /// - Parameters:
    ///   - onElapsed: (从订阅到当前 onNext 的耗时, 从订阅到流结束的耗时)
    /// - Returns: 原 Observable
    func measureStepTime(_ onElapsed: @escaping (_ totalElapsed: TimeUnit) -> Void) -> Observable<Element> {
        let sw = Stopwatch()
        return self.do(onError: { _ in
            onElapsed(sw.elapsed())
        }, onCompleted: {
            onElapsed(sw.elapsed())
        }, onSubscribe: {
            sw.start()
        })
    }

    /// 测量当前步骤的耗时
    /// - Parameters:
    ///   - identifier: 唯一标识,默认可以不写,那么就是文件+function+line
    ///   - warningTimeLimit: 警告时间上限,用于标记日志级别
    ///   - errorTimeLimit: 错误时间上限,用于标记日志级别
    ///   - file:源文件
    ///   - function: 源方法
    ///   - line: 源文件所在代码行数
    /// - Returns: 原流
    func measureStepTime(identifier: String? = nil,
                         warningTimeLimit: TimeUnit = .milliseconds(200),
                         errorTimeLimit: TimeUnit = .milliseconds(300),
                         file: String = #file,
                         function: String = #function,
                         line: Int = #line) -> Observable<Element>
    {
        measureStepTime { totalElapsed in
            XXFFlow.logTimingLogger(totalElapsed, identifier, warningTimeLimit, errorTimeLimit, file, function, line)
        }
    }

    /// 测量从订阅到当前节点执行完成的耗时
    /// - Parameters:
    ///   - onElapsed: (从订阅到当前 onNext 的耗时, 从订阅到流结束的耗时)
    /// - Returns: 原 Observable
    func measureChainElapsed(_ onElapsed: @escaping (_ totalElapsed: TimeUnit) -> Void) -> Observable<Element> {
        return Observable.deferred {
            self.asObservable()
        }.measureStepTime(onElapsed)
    }

    /// 测量从订阅到当前节点执行完成的耗时
    /// - Parameters:
    ///   - identifier: 唯一标识,默认可以不写,那么就是文件+function+line
    ///   - warningTimeLimit: 警告时间上限,用于标记日志级别
    ///   - errorTimeLimit: 错误时间上限,用于标记日志级别
    ///   - file:源文件
    ///   - function: 源方法
    ///   - line: 源文件所在代码行数
    /// - Returns: 原流
    func measureChainElapsed(identifier: String? = nil,
                             warningTimeLimit: TimeUnit = .milliseconds(200),
                             errorTimeLimit: TimeUnit = .milliseconds(300),
                             file: String = #file,
                             function: String = #function,
                             line: Int = #line) -> Observable<Element>
    {
        measureChainElapsed { totalElapsed in
            XXFFlow.logTimingLogger(totalElapsed, identifier, warningTimeLimit, errorTimeLimit, file, function, line)
        }
    }
}
