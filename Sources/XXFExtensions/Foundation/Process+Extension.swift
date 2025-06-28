//
//  Process+Extension.swift
//  xxf_ios
//  进程相关拓展
//  Created by xxf on 6/17.
//

import Darwin
import Foundation

public extension Process {
    /// 进程监听端口信息结构体
    /// 对应 lsof 命令输出的一行数据，代表一个监听 TCP 端口的进程信息
    struct ProcessInfo: CustomStringConvertible {
        /// 进程命令名称 (COMMAND)，比如 "file_manage_agent"
        public let command: String

        /// 进程ID (PID)
        public let pid: Int

        /// 进程所属用户 (USER)，通常是启动该进程的用户名
        public let user: String

        /// 文件描述符 (FD)，表示该进程打开的文件描述符标识，通常为数字加上类型字符
        public let fd: String

        /// 类型 (TYPE)，通常是文件类型，如 IPv4、IPv6 等
        public let type: String

        /// 设备号 (DEVICE)，设备相关信息，一般为文件系统设备号
        public let device: String

        /// 文件大小或偏移量 (SIZE/OFF)，一般表示文件大小或者偏移，针对套接字可能没意义
        public let sizeOff: String

        /// 节点号 (NODE)，文件系统的节点号，套接字时可能为空
        public let node: String

        /// 协议类型 (PROTOCOL)，如 TCP、UDP 等
        public let protocolType: String

        /// 本地监听地址 (LOCAL ADDRESS)，可能是IP地址或通配符(*)，表示监听的网络地址
        public let localAddress: String

        /// 本地监听端口 (PORT)
        public let port: Int

        /// 结构体的字符串描述，方便调试打印
        public var description: String {
            return "[\(command):\(pid)] user:\(user) fd:\(fd) type:\(type) device:\(device) sizeOff:\(sizeOff) node:\(node) protocol:\(protocolType) \(localAddress):\(port)"
        }
    }

    /// 返回所有监听指定端口的进程信息
    static func getProcessesListening(onPort port: Int) -> [ProcessInfo] {
        let allProcesses = getProcessInfo()
        return allProcesses.filter { $0.port == port }
    }

    /// 查找可用的端口
    /// - Parameters:
    ///   - range: 端口区间
    ///   - count: 结果最大数量
    /// - Returns: 可用的端口
    static func findAvailablePorts(
        in range: Range<Int> = 8081 ..< 65535,
        count: Int
    ) -> [Int] {
        precondition(count > 0, "❌ count 必须大于 0")
        let legalPortRange = 1 ..< 65536
        precondition(
            legalPortRange.overlaps(range),
            "❌ The port range must intersect with 1..<65536"
        )

        var result: [Int] = []
        /// shuffled 有助于业务的正确性
        for port in range.shuffled() {
            if !Process.isPortInUsing(port) {
                result.append(port)
            }
            if result.count >= count {
                break
            }
        }
        return result
    }

    /// 判断指定端口是否被占用
    static func isPortInUsing(_ port: Int) -> Bool {
        return !isPortAvailable(port) || !getProcessesListening(onPort: port).isEmpty
    }

    /// 端口是否可用
    private static func isPortAvailable(_ port: Int) -> Bool {
        var addr = sockaddr_in()
        addr.sin_len = __uint8_t(MemoryLayout<sockaddr_in>.size)
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(UInt16(port).bigEndian)
        addr.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))
        addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)

        let sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
        guard sock >= 0 else {
            return false
        }

        defer {
            close(sock)
        }

        // 设置 socket 选项 SO_REUSEADDR 防止 TIME_WAIT 状态影响端口占用判断
        var yes: Int32 = 1
        setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &yes, socklen_t(MemoryLayout<Int32>.size))

        let result = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { sockaddrPtr in
                Darwin.bind(sock, sockaddrPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        return result == 0
    }

    /// 查询进程
    static func getProcessInfo(filterProcessName: String? = nil) -> [ProcessInfo] {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        task.arguments = ["-iTCP", "-sTCP:LISTEN", "-n", "-P"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
        } catch {
            print("Failed to run lsof: \(error)")
            return []
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else {
            print("Failed to decode lsof output")
            return []
        }

        let lines = output.split(separator: "\n")
        // 第一行为表头，跳过
        guard lines.count > 1 else { return [] }

        var results: [ProcessInfo] = []

        for line in lines.dropFirst() {
            // 按空白拆分（连续空白作为分割）
            // lsof有些字段间可能有多个空格或制表符
            let parts = line.split(whereSeparator: { $0.isWhitespace }).map(String.init)

            // lsof的字段有时会因为command名字长度不同导致对齐变化，简单做字段数判断
            // 预期字段个数一般是9或者10，最后一项是NAME字段，里面包含地址和端口
            guard parts.count >= 9 else {
                continue
            }

            // fields index:
            // 0: COMMAND
            // 1: PID
            // 2: USER
            // 3: FD
            // 4: TYPE
            // 5: DEVICE
            // 6: SIZE/OFF
            // 7: NODE
            // 8: NAME (含协议和地址端口)

            let command = parts[0]
            guard let pid = Int(parts[1]) else { continue }
            let user = parts[2]
            let fd = parts[3]
            let type = parts[4]
            let device = parts[5]
            let sizeOff = parts[6]
            let node = parts[7]
            let name = parts[8]

            // name 一般格式: "TCP *:8082 (LISTEN)"
            // 提取协议、地址和端口
            // 按空格分三部分，第一是协议，第二是地址:端口，第三是状态 (括号里)
            let nameParts = name.split(separator: " ")

            guard nameParts.count >= 2 else {
                continue
            }

            let protocolType = String(nameParts[0]) // TCP
            let addressPort = String(nameParts[1]) // *:8082 或 127.0.0.1:8082

            // 解析 addressPort 拆分地址和端口
            // 这里支持 IPv4、IPv6（带中括号）格式，简单处理：
            var localAddress = ""
            var port = 0

            if let colonIndex = addressPort.lastIndex(of: ":") {
                localAddress = String(addressPort.prefix(upTo: colonIndex))
                let portStr = String(addressPort.suffix(from: addressPort.index(after: colonIndex)))
                port = Int(portStr) ?? 0
            } else {
                localAddress = addressPort
            }

            // 过滤指定 command 名称（如果传入了）
            if let filter = filterProcessName, filter != command {
                continue
            }

            let info = ProcessInfo(
                command: command,
                pid: pid,
                user: user,
                fd: fd,
                type: type,
                device: device,
                sizeOff: sizeOff,
                node: node,
                protocolType: protocolType,
                localAddress: localAddress,
                port: port
            )

            results.append(info)
        }

        return results
    }

    /// 按进程名字来杀掉进程
    @discardableResult
    static func killProcesses(processName: String) -> Bool {
        let pkillTask = Process()
        pkillTask.launchPath = "/usr/bin/pkill"
        pkillTask.arguments = ["-x", processName] // 精确匹配名称
        pkillTask.launch()
        pkillTask.waitUntilExit()

        if pkillTask.terminationStatus == 0 {
            return true
        } else {
            return false
        }
    }

    /// 检查指定端口是否可以在本地连接（连接成功即认为端口开放）
    ///
    /// - Parameter port: 要检查的本地端口号（如 8080）
    /// - Returns: 如果端口可连接，返回 true；否则返回 false
    private static func isPortOpen(_ port: Int) -> Bool {
        // 构造 IPv4 地址结构体
        var sin = sockaddr_in()
        sin.sin_family = sa_family_t(AF_INET) // 使用 IPv4
        sin.sin_port = in_port_t(UInt16(port).bigEndian) // 设置端口（注意使用大端序）
        sin.sin_addr.s_addr = inet_addr("127.0.0.1") // 设置本地地址（127.0.0.1）

        // 创建 socket，参数含义：
        // AF_INET：IPv4
        // SOCK_STREAM：TCP 连接
        // 0：默认协议（TCP）
        let sock = socket(AF_INET, SOCK_STREAM, 0)
        guard sock >= 0 else {
            // socket 创建失败，直接返回 false
            return false
        }
        defer {
            // 函数退出时关闭 socket 释放资源
            close(sock)
        }

        // 调用 connect() 尝试连接该端口
        let result = withUnsafePointer(to: &sin) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                connect(sock, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        // connect 返回 0 表示连接成功，即端口开放
        return result == 0
    }

    /// 等待某个端口在本地变为可连接状态（用于判断进程是否成功启动监听）
    ///
    /// - Parameters:
    ///   - port: 目标端口号（如 8082）
    ///   - timeout: 最长等待时间（秒），默认 5 秒
    ///   - interval: 每次尝试之间的间隔（秒），默认 0.1 秒
    /// - Returns: 如果端口在 timeout 之前变为可连接，返回 true；否则返回 false
    static func waitForPort(_ port: Int, timeout: TimeInterval = 5.0, interval: TimeInterval = 0.1) -> Bool {
        let deadline = Date().addingTimeInterval(timeout) // 计算超时时间点
        while Date() < deadline {
            if isPortOpen(port) {
                return true
            }
            // 等待一段时间后再次尝试
            Thread.sleep(forTimeInterval: interval)
        }
        // 超时仍未开放
        return false
    }
}
