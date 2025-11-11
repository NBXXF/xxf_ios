//
//  Environment.swift
//  xxf_ios
//  环境相关
//  Created by xxf on 6/11.
//
import Darwin
import Foundation

public enum Environment {
    public static let isDebug: Bool = {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }()

    /// 是否 被调试器（debugger）附加（attach),不能lazy,可能在程序过程中挂上
    public static var isDebuggerAttached: Bool {
        var info = kinfo_proc()
        let mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride

        var mibCopy = mib
        let mibCount = UInt32(mibCopy.count) // 提前保存长度

        let result = mibCopy.withUnsafeMutableBufferPointer { mibPtr -> Int32 in
            return withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: UInt8.self, capacity: size) { infoPtr in
                    sysctl(mibPtr.baseAddress, mibCount, infoPtr, &size, nil, 0)
                }
            }
        }

        if result != 0 {
            perror("sysctl failed")
            return false
        }

        return (info.kp_proc.p_flag & P_TRACED) != 0
    }

    /// 是否是从单元测试中启动
    public static let isRunningUnitTests: Bool = {
        let env = ProcessInfo.processInfo.environment
        let args = ProcessInfo.processInfo.arguments

        // 1. 通过环境变量判断 XCTest 是否存在
        if env["XCTestConfigurationFilePath"] != nil {
            return true
        }

        // 2. 通过进程启动参数判断常见测试标记
        let testArguments = ["-XCTest", "UITest", "test", "TEST"]
        for arg in args {
            if testArguments.contains(where: arg.contains) {
                return true
            }
        }

        // 3. 通过检查 XCTest 框架是否加载 (可选，较复杂)
        // 这里示例暂不实现

        return false
    }()
}
