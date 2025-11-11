import Foundation

//  BlockWatcher.swift
//  监控卡顿
//  Created by XXF on 2022/12/31.
//
public final class BlockWatcher: NSObject {
    fileprivate let pingThread: WatchThread

    @objc public static let defaultThreshold = 0.4

    /// - parameter threshold: 卡顿时间 单位为s.
    /// - parameter strictMode: 区分是打印日志还是报错.
    @objc public convenience init(threshold: Double = BlockWatcher.defaultThreshold, strictMode: Bool = false) {
        let message = "👮 Main thread was blocked for " + String(format: "%.2f", threshold) + "s 👮"

        self.init(threshold: threshold) {
            if strictMode {
                // 主线程卡顿了 请用xcode 切换MainThread 查看
                fatalError(message)
            } else {
                NSLog("%@", message)
            }
        }
    }

    @objc public init(threshold: Double = BlockWatcher.defaultThreshold, watchdogFiredCallback: @escaping () -> Void) {
        pingThread = WatchThread(threshold: threshold, handler: watchdogFiredCallback)

        pingThread.start()
        super.init()
    }

    deinit {
        pingThread.cancel()
    }
}

@preconcurrency
private final class WatchThread: Thread {
    fileprivate var pingTaskIsRunning: Bool {
        get {
            objc_sync_enter(pingTaskIsRunningLock)
            let result = _pingTaskIsRunning
            objc_sync_exit(pingTaskIsRunningLock)
            return result
        }
        set {
            objc_sync_enter(pingTaskIsRunningLock)
            _pingTaskIsRunning = newValue
            objc_sync_exit(pingTaskIsRunningLock)
        }
    }

    private var _pingTaskIsRunning = false
    private let pingTaskIsRunningLock = NSObject()
    fileprivate var semaphore = DispatchSemaphore(value: 0)
    fileprivate let threshold: Double
    fileprivate let handler: () -> Void

    init(threshold: Double, handler: @escaping () -> Void) {
        self.threshold = threshold
        self.handler = handler
        super.init()
        name = "BlockWatcher"
    }

    override func main() {
        while !isCancelled {
            pingTaskIsRunning = true
            DispatchQueue.main.async {
                self.pingTaskIsRunning = false
                self.semaphore.signal()
            }

            Thread.sleep(forTimeInterval: threshold)
            if pingTaskIsRunning {
                handler()
            }

            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
    }
}
