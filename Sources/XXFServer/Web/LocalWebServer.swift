//
//  LocalWebServer.swift
//  XXFServer
//  web本地服务器/仅仅限于测试
//  Created by xxf on 6/2.
//

import Foundation
import GCDWebServer
import XXFFoundation

/// 本地 HTTP 服务,用于把沙盒里的本地目录以 `http://127.0.0.1:PORT/<token>/...` 形式暴露给 WKWebView。
///
/// 用途:
/// - `WKWebView.loadFileURL(...)` 下 `fetch` / ESM / Web Worker / IndexedDB 等受 same-origin 限制;
///   通过本地 HTTP 加载可解除这些限制,Cookie 行为也更接近真实 web。
///
/// 设计要点(多路复用):
/// - **单实例、单端口**:全局一个 `GCDWebServer`,无论多少个 WebView 并存都共享
/// - **path 前缀隔离**:每个调用者分配一个 token,URL 形如 `http://127.0.0.1:54321/<token>/entry.html`,
///   server 收到请求时按 token 查表路由到对应目录,互不串扰
/// - **显式释放**:调用方在 cell 复用 / deinit 时必须 `release(token:)`
///
/// 安全:handler 会验证请求路径归一化后仍在 session root 下,防止 `../` 路径穿越。
///
/// 端口说明:用 `GCDWebServerOption_Port: 0`,由 OS 分配一个空闲高位端口,不会和其他应用冲突。
///
/// 后台挂起:依赖 `GCDWebServerOption_AutomaticallySuspendInBackground`,进入后台自动 stop、
/// 回前台自动 restart,不需要额外的 NotificationCenter 监听。
public final class LocalWebServer {
    public static let shared = LocalWebServer()

    /// 日志等级。由外部 `printer` 自行决定如何落地(控制台/文件/埋点等)。
    public enum LogLevel: String {
        case info
        case warning
        case error
    }

    /// 可注入日志打印器。
    /// - Parameters:
    ///   - level: 日志等级
    ///   - message: 日志文本
    public typealias Printer = (_ level: LogLevel, _ message: String) -> Void

    /// session 句柄。只能由 `LocalWebServer` 创建;持有者负责在不再需要时传回给 `release(token:)`。
    public struct Token: Equatable, Hashable {
        fileprivate let value: String
    }

    /// 一次 `serve` 调用的返回结果。
    /// 独立成 struct 而不是元组,方便后续扩展(例如加 expiryDate、directoryPath 等字段)不破坏调用方。
    public struct Session: Equatable {
        /// WebView 加载用的入口 URL(形如 `http://127.0.0.1:PORT/<token>/<entry>`)
        public let url: URL
        /// 释放 session 用的句柄,用完必须 `LocalWebServer.shared.release(token:)`
        public let token: Token
    }

    /// 超过此阈值就认为调用方大概率有 release 泄漏,打一次 warn 日志。
    /// 日常 Feed 场景并存的 WebView 不会超过个位数,50 是一个宽松到不会误报的阈值。
    private static let sessionLeakWarnThreshold = 50

    private let server = GCDWebServer()
    /// 保护 `sessions` 字典的读写
    private let sessionLock = NSLock()
    /// 保护 `ensureRunning` 对 `server.start` 的并发调用
    private let startLock = NSLock()
    /// 保护 `printer` 的并发读写
    private let printerLock = NSLock()
    /// token -> 该 session 对应的本地根目录(绝对路径,已 standardized)
    private var sessions: [String: String] = [:]
    /// 只希望泄漏告警打一次,避免刷屏
    private var sessionLeakWarned = false
    /// 默认不打印,由外部按需注入真实日志实现
    private var _printer: Printer?

    private init() {
        registerHandler()
    }

    // MARK: - Public API

    /// 将本地目录暴露为一个独立的 URL 空间。
    /// - Parameters:
    ///   - directory: 本地绝对目录
    ///   - entryRelativePath: 相对 `directory` 的入口文件路径,默认 `index.html`
    /// - Returns: 封装了 url + token 的 `Session`;启动失败返回 nil。
    ///   调用方必须持有 `session.token` 并在结束时 `release(token:)`。
    public func serve(directory: String, entryRelativePath: String = "index.html") -> Session? {
        // root 入表前先 standardize,handler 里的防穿越校验才能基于干净的前缀做字符串比较
        let normalizedRoot = URL(fileURLWithPath: directory).standardizedFileURL.path

        let raw = newTokenValue()
        register(token: raw, root: normalizedRoot)

        guard ensureRunning(), let port = currentPort() else {
            unregister(token: raw)
            return nil
        }

        let entry = entryRelativePath.hasPrefix("/")
            ? String(entryRelativePath.dropFirst())
            : entryRelativePath
        let encoded = entry.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? entry

        guard let url = URL(string: "http://127.0.0.1:\(port)/\(raw)/\(encoded)") else {
            unregister(token: raw)
            return nil
        }
        return Session(url: url, token: Token(value: raw))
    }

    /// 按单文件暴露的便捷方法:以文件父目录作为 root,入口为文件本身。
    public func serve(localFilePath: String) -> Session? {
        let fileURL = URL(fileURLWithPath: localFilePath)
        return serve(
            directory: fileURL.deletingLastPathComponent().path,
            entryRelativePath: fileURL.lastPathComponent
        )
    }

    /// 释放 session。释放后,该 token 对应的 URL 返回 404。
    /// 幂等:重复 release 同一个 token 不会报错。
    public func release(token: Token) {
        unregister(token: token.value)
    }

    /// 当前存活的 session 数量。主要用于调试和监控,发现 release 泄漏。
    public var activeSessionCount: Int {
        sessionLock.lock()
        defer { sessionLock.unlock() }
        return sessions.count
    }

    /// 注入日志打印器。传 `nil` 可关闭日志输出。
    public var printer: Printer? {
        get {
            printerLock.lock()
            defer { printerLock.unlock() }
            return _printer
        }
        set {
            printerLock.lock()
            _printer = newValue
            printerLock.unlock()
        }
    }

    // MARK: - Private (state)

    private func newTokenValue() -> String {
        return randomUUIDString32()
    }

    private func register(token: String, root: String) {
        sessionLock.lock()
        sessions[token] = root
        let count = sessions.count
        let shouldWarn = !sessionLeakWarned && count > Self.sessionLeakWarnThreshold
        if shouldWarn {
            sessionLeakWarned = true
        }
        sessionLock.unlock()

        if shouldWarn {
            emitLog(.warning, "[LocalWebServer] session 数达到 \(count),疑似 release 泄漏,请检查调用方是否在 cell 复用/deinit 时调用了 release(token:)")
        }
    }

    private func unregister(token: String) {
        sessionLock.lock()
        sessions.removeValue(forKey: token)
        sessionLock.unlock()
    }

    private func lookupRoot(for token: String) -> String? {
        sessionLock.lock()
        defer { sessionLock.unlock() }
        return sessions[token]
    }

    // MARK: - Private (server)

    private func currentPort() -> UInt? {
        let port = server.port
        return port > 0 ? port : nil
    }

    /// 幂等的启动。用 `startLock` 串行化,避免两个线程同时首次调用时 `server.start` 二次抛错。
    @discardableResult
    private func ensureRunning() -> Bool {
        startLock.lock()
        defer { startLock.unlock() }
        if server.isRunning { return true }
        do {
            try server.start(options: [
                GCDWebServerOption_Port: NSNumber(value: 0),
                GCDWebServerOption_BindToLocalhost: NSNumber(value: true),
                GCDWebServerOption_AutomaticallySuspendInBackground: NSNumber(value: true)
            ])
            return true
        } catch {
            emitLog(.error, "[LocalWebServer] start failed: \(error)")
            return false
        }
    }

    /// 注册 GET / HEAD handler(WKWebView 偶尔发 HEAD 做探测)。
    /// 单一动态 handler:按 `/<token>/<rest>` 解析,token 查表路由到 root。
    private func registerHandler() {
        let processBlock: (GCDWebServerRequest) -> GCDWebServerResponse? = { [weak self] request in
            guard let self = self else {
                return GCDWebServerResponse(statusCode: 404)
            }
            return self.handle(request: request)
        }
        for method in ["GET", "HEAD"] {
            server.addHandler(
                forMethod: method,
                pathRegex: ".*",
                request: GCDWebServerRequest.self,
                processBlock: processBlock
            )
        }
    }

    /// 核心路由 + 安全校验。
    private func handle(request: GCDWebServerRequest) -> GCDWebServerResponse? {
        // 1. 拆 token + 相对路径
        let fullPath = request.path
        let stripped = fullPath.hasPrefix("/") ? String(fullPath.dropFirst()) : fullPath

        guard let slashIdx = stripped.firstIndex(of: "/") else {
            // 只有 token、没有相对路径(例如 /token):当前不支持目录索引,返回 404
            return GCDWebServerResponse(statusCode: 404)
        }
        let token = String(stripped[..<slashIdx])
        let relativeRaw = String(stripped[stripped.index(after: slashIdx)...])
        var relative = relativeRaw.removingPercentEncoding ?? relativeRaw

        // 2. 查 session
        guard let root = lookupRoot(for: token) else {
            return GCDWebServerResponse(statusCode: 404)
        }

        // 3. 目录结尾 → 自动补 index.html(常见 SPA 路由约定)
        if relative.isEmpty || relative.hasSuffix("/") {
            relative += "index.html"
        }

        // 4. 拼路径并 standardize,校验没跑出 root(防 `../` 穿越)
        let rawTarget = (root as NSString).appendingPathComponent(relative)
        let targetStandardized = URL(fileURLWithPath: rawTarget).standardizedFileURL.path

        guard targetStandardized == root || targetStandardized.hasPrefix(root + "/") else {
            emitLog(.warning, "[LocalWebServer] path traversal blocked: \(fullPath)")
            return GCDWebServerResponse(statusCode: 403)
        }

        // 5. 读文件
        guard let response = GCDWebServerFileResponse(file: targetStandardized, byteRange: request.byteRange) else {
            return GCDWebServerResponse(statusCode: 404)
        }
        response.cacheControlMaxAge = 0
        return response
    }

    private func emitLog(_ level: LogLevel, _ message: String) {
        printerLock.lock()
        let printer = _printer
        printerLock.unlock()
        printer?(level, message)
    }
}
