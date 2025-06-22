//
//  Memorying.swift
//  xxf_ios
//
//  Created by trl on 6/11.
//
import Darwin // for getrusage, mach APIs
import Darwin.Mach
import Foundation

/// 返回当前进程的物理内存使用量（单位：字节）
@inlinable
@inline(__always)
public func currentMemoryUsage() -> UInt64 {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: info)) / 4

    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            task_info(
                task_self_trap(), // ✅ 替代 mach_task_self_
                task_flavor_t(MACH_TASK_BASIC_INFO),
                $0,
                &count
            )
        }
    }

    if result == KERN_SUCCESS {
        return info.resident_size
    } else {
        return 0
    }
}

/// 测量内存占用
/// - Parameter block: 执行单元
/// - Returns: 内存占用 字节
@inlinable
@inline(__always)
func measureMemoryUsage(of block: () -> Void) -> UInt64 {
    let before = currentMemoryUsage()
    block()
    let after = currentMemoryUsage()
    return after >= before ? after - before : 0
}

/// 测量内存占用
/// - Parameters:
///   - onlyDebug: 是否只在debug模式生效
///   - block: 执行单元
/// - Returns: 内存占用 字节
@discardableResult
@inlinable
@inline(__always)
public func measureMemoryUsage(onlyDebug: Bool = true, _ block: () -> Void) -> UInt64 {
    #if DEBUG
        return measureMemoryUsage(of: block)
    #else
        if onlyDebug {
            block()
            return 0
        } else {
            return measureMemoryUsage(of: block)
        }
    #endif
}

/// 测量内存占用（单位：KB）
/// - Parameters:
///   - onlyDebug: 是否只在debug模式生效
///   - block: 执行单元
/// - Returns: 内存占用，单位：千字节（KB），支持小数
@discardableResult
@inlinable
@inline(__always)
public func measureMemoryUsageKB(onlyDebug: Bool = true, _ block: () -> Void) -> Double {
    Double(measureMemoryUsage(onlyDebug: onlyDebug, block)) / 1024
}

/// 测量内存占用（单位：MB）
/// - Parameters:
///   - onlyDebug: 是否只在debug模式生效
///   - block: 执行单元
/// - Returns: 内存占用，单位：兆字节（MB），支持小数
@discardableResult
@inlinable
@inline(__always)
public func measureMemoryUsageMB(onlyDebug: Bool = true, _ block: () -> Void) -> Double {
    Double(measureMemoryUsage(onlyDebug: onlyDebug, block)) / (1024 * 1024)
}
