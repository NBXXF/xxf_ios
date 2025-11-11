//
//  NetworkMonitor.swift
//  xxf_ios
//  网络状态观察
//  Created by xxf on 6/29.
//

import Network
import RxRelay
import RxSwift

public final class NetworkMonitor: @unchecked Sendable {
    public static let shared = NetworkMonitor()

    private var monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.xxf.network.monitor")
    private var isMonitoring = false

    private let subject = PublishRelay<NetworkStatus>()

    private init() {
        monitor = NWPathMonitor()
    }

    public func startMonitoring() {
        guard !isMonitoring else { return }
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            let status: NetworkStatus
            if path.status == .satisfied {
                let type = NetworkMonitor.getNetworkType(path)
                status = .connected(type)
            } else {
                status = .disconnected
            }
            self.subject.accept(status)
        }
        monitor.start(queue: queue)
        isMonitoring = true
    }

    public func stopMonitoring() {
        guard isMonitoring else { return }
        monitor.cancel()
        isMonitoring = false
    }

    public func observeNetworkChanges() -> Observable<NetworkStatus> {
        startMonitoring()
        return subject
            .distinctUntilChanged()
            .asObservable()
    }

    /// 获取当前网络状态（立即返回，不需要订阅）
    public func currentNetworkStatus() -> NetworkStatus {
        return NetworkMonitor.status(for: monitor.currentPath)
    }

    private static func status(for path: NWPath) -> NetworkStatus {
        if path.status == .satisfied {
            return .connected(getNetworkType(path))
        } else {
            return .disconnected
        }
    }

    private static func getNetworkType(_ path: NWPath) -> NetworkType {
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.cellular) { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .ethernet }
        if path.usesInterfaceType(.loopback) { return .loopback }
        if path.usesInterfaceType(.other) { return .other }
        return .unknown
    }
}
