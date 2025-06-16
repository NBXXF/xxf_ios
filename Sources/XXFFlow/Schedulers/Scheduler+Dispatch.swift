//
//  Scheduler+Dispatch.swift
//  xxf_ios
//  可直接执行任务指定线程
//  Created by xxf on 6/7.
//

import Foundation
import RxSwift

// MARK: - 通用调度封装

/// 立即执行任务，并在指定的 ImmediateSchedulerType 上订阅
/// - Parameters:
///   - scheduler: 指定调度器（通常是 ImmediateSchedulerType 的实例）
///   - run: 要执行的任务闭包
/// - Returns: 返回一个 Disposable，可以用于取消任务
@discardableResult
public func scheduleDirect(scheduler: ImmediateSchedulerType, _ run: @escaping () -> Void) -> Disposable {
    return Observable<Void>.create { observer in
        run()
        observer.onCompleted()
        return Disposables.create()
    }
    .subscribe(on: scheduler)
    .subscribe()
}

/// 延迟执行任务，在指定的 SchedulerType 上调度
/// - Parameters:
///   - scheduler: 指定调度器
///   - delay: 延迟时间，RxTimeInterval 类型
///   - run: 要执行的任务闭包
/// - Returns: 返回一个 Disposable，可用于取消任务
@discardableResult
public func scheduleDirect(scheduler: SchedulerType, delay: RxTimeInterval, _ run: @escaping () -> Void) -> Disposable {
    return Observable<Void>.just(())
        .delay(delay, scheduler: scheduler)
        .do(onNext: { run() })
        .subscribe()
}

// MARK: - 各种 Scheduler 调用封装

// MARK: Main 线程调度

/// 主线程立即执行任务
/// - Parameter run: 要执行的任务闭包
/// - Returns: Disposable
@discardableResult
public func scheduleDirectOnMain(_ run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.main(), run)
}

/// 主线程延迟执行任务
/// - Parameters:
///   - delay: 延迟时间
///   - run: 要执行的任务闭包
/// - Returns: Disposable
@discardableResult
public func scheduleDirectOnMain(delay: RxTimeInterval, _ run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.main(), delay: delay, run)
}

// MARK: IO 线程调度

/// IO线程立即执行任务
/// - Parameter run: 要执行的任务闭包
/// - Returns: Disposable
@discardableResult
public func scheduleDirectOnIO(_ run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.io(), run)
}

/// IO线程延迟执行任务
/// - Parameters:
///   - delay: 延迟时间
///   - run: 要执行的任务闭包
/// - Returns: Disposable
@discardableResult
public func scheduleDirectOnIO(delay: RxTimeInterval, _ run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.io(), delay: delay, run)
}

// MARK: 计算线程调度

/// 计算线程立即执行任务
/// - Parameter run: 要执行的任务闭包
/// - Returns: Disposable
@discardableResult
public func scheduleDirectOnComputation(_ run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.computation(), run)
}

/// 计算线程延迟执行任务
/// - Parameters:
///   - delay: 延迟时间
///   - run: 要执行的任务闭包
/// - Returns: Disposable
@discardableResult
public func scheduleDirectOnComputation(delay: RxTimeInterval, _ run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.computation(), delay: delay, run)
}

// MARK: 新线程调度

/// 新线程立即执行任务
/// - Parameter run: 要执行的任务闭包
/// - Returns: Disposable
@discardableResult
public func scheduleDirectOnNewThread(_ run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.newThread(), run)
}

/// 新线程延迟执行任务
/// - Parameters:
///   - delay: 延迟时间
///   - run: 要执行的任务闭包
/// - Returns: Disposable
@discardableResult
public func scheduleDirectOnNewThread(delay: RxTimeInterval, _ run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.newThread(), delay: delay, run)
}

// MARK: 单线程调度

/// 单线程立即执行任务
/// - Parameter run: 要执行的任务闭包
/// - Returns: Disposable
@discardableResult
public func scheduleDirectOnSingle(_ run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.single(), run)
}

/// 单线程延迟执行任务
/// - Parameters:
///   - delay: 延迟时间
///   - run: 要执行的任务闭包
/// - Returns: Disposable
@discardableResult
public func scheduleDirectOnSingle(delay: RxTimeInterval, _ run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: Schedulers.single(), delay: delay, run)
}

// MARK: 当前线程（Trampoline）调度

/// 当前线程立即执行任务
/// - Parameter run: 要执行的任务闭包
/// - Returns: Disposable
@discardableResult
public func scheduleDirectOnTrampoline(_ run: @escaping () -> Void) -> Disposable {
    return scheduleDirect(scheduler: CurrentThreadScheduler.instance, run)
}

// 延迟版本如需可自行开启
// /// 当前线程延迟执行任务
// /// - Parameters:
// ///   - delay: 延迟时间
// ///   - run: 要执行的任务闭包
// /// - Returns: Disposable
// @discardableResult
// public func scheduleDirectOnTrampoline(delay: RxTimeInterval, _ run: @escaping () -> Void) -> Disposable {
//     return scheduleDirect(scheduler: CurrentThreadScheduler.instance, delay: delay, run)
// }
