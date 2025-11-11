//
//  Schedulers.swift
//  xxf_ios
//
//  Created by xxf on 5/27.
//

import CoreFoundation
import Dispatch
import Foundation
@preconcurrency import RxSwift

/// 调度器统一封装，参考 RxJava 的 Schedulers 设计风格
/// 提供常用调度器（主线程、IO、计算、新线程、单线程等）
/// 可避免业务层频繁创建调度器对象，提升代码一致性与性能
public enum Schedulers {
    /// 对应 RxJava 的 Schedulers.io()
    /// 适合 I/O 密集型操作（文件、网络等），具有较低的优先级和并发性能
    private static let _io = ConcurrentDispatchQueueScheduler(dispatchQoS: .utility) { queue in
        queue.setSpecific(key: DispatchQueueType.specificKey, value: .io)
    }

    /// 对应 RxJava 的 Schedulers.computation()
    /// 适合 CPU 密集型计算任务，如图片处理、压缩等，具有较高优先级
    private static let _computation = ConcurrentDispatchQueueScheduler(dispatchQoS: .userInitiated) { queue in
        queue.setSpecific(key: DispatchQueueType.specificKey, value: .computation)
    }

    /// 对应 AndroidSchedulers.mainThread()
    /// 主线程调度器，用于 UI 操作、响应式绑定等
    private static let _main = MainScheduler.instance

    /// 对应主线程runloop的common mode，处理一些在模态下要触发的信号更新
    private static let _mainCommonMode = MainCommonModeScheduler.instance

    /// 对应 RxJava 的 Schedulers.single()
    /// 单线程调度器，适合顺序任务处理，保证串行执行
    private static let _single = SerialDispatchQueueScheduler(internalSerialQueueName: "rx.single") { queue in
        queue.setSpecific(key: DispatchQueueType.specificKey, value: .single)
    }

    /// 后台调度器（最低优先级）
    /// 适合日志、缓存清理等低优先级任务
    private static let _background = ConcurrentDispatchQueueScheduler(dispatchQoS: .background) { queue in
        queue.setSpecific(key: DispatchQueueType.specificKey, value: .background)
    }

    /// 用户交互调度器（最高优先级之一）
    /// 适合需要尽快影响 UI 的紧急任务，如动画数据准备
    private static let _userInteractive = ConcurrentDispatchQueueScheduler(dispatchQoS: .userInteractive) { queue in
        queue.setSpecific(key: DispatchQueueType.specificKey, value: .userInteractive)
    }

    /// 排队到当前线程中顺序执行
    private static let _trampoline = CurrentThreadScheduler.instance

    /// 获取 IO 调度器
    public static func io() -> ConcurrentDispatchQueueScheduler {
        return _io
    }

    /// 获取计算型调度器
    public static func computation() -> SchedulerType {
        return _computation
    }

    /// 获取主线程调度器
    public static func main() -> SchedulerType {
        return _main
    }

    /// 对应主线程runloop的common mode，处理一些在模态下要触发的信号更新
    public static func mainCommonMode() -> ImmediateSchedulerType {
        return _mainCommonMode
    }

    /// 获取单线程调度器（串行执行）
    public static func single() -> SchedulerType {
        return _single
    }

    /// 模拟 RxJava 的 Schedulers.newThread()
    /// 每次调用创建一个新调度器（由 GCD 实际管理线程复用）
    public static func newThread() -> SchedulerType {
        return ConcurrentDispatchQueueScheduler(qos: .default)
    }

    /// 获取后台调度器（最低优先级）
    /// 适用于不重要的后台任务，如数据缓存、日志处理等
    public static func background() -> SchedulerType {
        return _background
    }

    /// 获取用户交互优先级调度器
    /// 不建议业务层主动使用，适合框架内部执行紧急任务
    @available(*, deprecated, message: "不建议使用,容易导致app卡死")
    public static func userInteractive() -> SchedulerType {
        return _userInteractive
    }

    /// 创建自定义串行调度器
    /// - Warning: 不建议业务层使用，建议自行管理线程
    @available(*, deprecated, message: "建议业务自己管理")
    public static func serial(label: String) -> SchedulerType {
        SerialDispatchQueueScheduler(internalSerialQueueName: label)
    }

    /// 创建自定义并发调度器
    /// - Warning: 不建议业务层使用，建议自行管理线程
    @available(*, deprecated, message: "建议业务自己管理")
    public static func concurrent(qos: DispatchQoS.QoSClass) -> SchedulerType {
        ConcurrentDispatchQueueScheduler(qos: DispatchQoS(qosClass: qos, relativePriority: 0))
    }

    /// 排队到当前线程中顺序执行
    public static func trampoline() -> ImmediateSchedulerType {
        return _trampoline
    }
}
