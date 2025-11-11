//
//  MainCommonModeScheduler.swift
//  xxf_ios
//
//  Created by xxf on 9/14.
//
import Foundation

/// 解决滚动状态下面,rxswift 无法监听信号,主线程问题
public final class MainCommonModeScheduler: ImmediateSchedulerType, @unchecked Sendable {
    public static let instance = MainCommonModeScheduler()

    private init() {}

    public func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let disposable = SingleAssignmentDisposable()

        CFRunLoopPerformBlock(CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue) {
            if !disposable.isDisposed {
                disposable.setDisposable(action(state))
            }
        }
        CFRunLoopWakeUp(CFRunLoopGetMain())

        return disposable
    }
}
