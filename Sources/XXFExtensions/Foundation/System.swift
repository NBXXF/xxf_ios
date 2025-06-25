//
//  System.swift
//  xxf_ios
//  系统性拓展
//  Created by xxf on /6/10.
//

import Darwin
import Foundation

public enum System {
    /// macOS 和 iOS 系统默认的换行符是 "\n"
    public static var lineSeparator: String {
        #if os(Windows)
            return "\r\n"
        #else
            return "\n"
        #endif
    }

    /// 文件分割符
    public static var fileSeparator: String {
        #if os(Windows)
            return "\\"
        #else
            return "/"
        #endif
    }

    /// ProcessInfo.processInfo.operatingSystemVersionString  不能识别 iPadOS/visionOS watchOS
    public static var osName: String {
        #if os(macOS)
            return "macOS"
        #elseif os(iOS)
            return "iOS"
        #elseif os(tvOS)
            return "tvOS"
        #elseif os(watchOS)
            return "watchOS"
        #elseif os(visionOS)
            return "visionOS"
        #elseif os(Linux)
            return "Linux"
        #elseif os(Windows)
            return "Windows"
        #else
            return "Unknown"
        #endif
    }

    /// 示例：macOS 14.4.1、iOS 17.5
    public static var osVersion: String {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    }

    public static var timestampMillis: Int {
        Int(Date().timeIntervalSince1970 * 1000)
    }

    /// 是否 被调试器（debugger）附加（attach）
    public func isDebuggerAttached() -> Bool {
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
    public func isRunningUnitTests() -> Bool {
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
    }
}
