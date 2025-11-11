////
////  Session+Copy.swift
////  xxf_ios
////
////  Created by xxf on 6/22.
////
// import Moya
//
// extension Session {
//    func copy(_ type: RestApiService.Type) -> Session {
//        let configuration = session.configuration
//        let delegate = self.delegate
//        let rootQueue = self.rootQueue
//        let startRequestsImmediately = self.startRequestsImmediately
//        let requestQueue = self.requestQueue
//        let serializationQueue = self.serializationQueue
//        let interceptor = self.interceptor ?? type.interceptor
//        let serverTrustManager = self.serverTrustManager
//        let redirectHandler = self.redirectHandler
//        let cachedResponseHandler = self.cachedResponseHandler
//        // TODO: 私有
//        let eventMonitors = eventMonitor.monitors
//
//        // 2. 如果其中没有 NetworkLoggerEventMonitor，就自动添加一个
//        if !eventMonitors.contains(where: { $0 is LoggerEventMonitor }) {
//            eventMonitors.append(LoggerEventMonitor.shared)
//        }
//        return Session(
//            configuration: configuration,
//            delegate: delegate,
//            rootQueue: rootQueue,
//            startRequestsImmediately: startRequestsImmediately,
//            requestQueue: requestQueue,
//            serializationQueue: serializationQueue,
//            interceptor: interceptor,
//            serverTrustManager: serverTrustManager,
//            redirectHandler: redirectHandler,
//            cachedResponseHandler: cachedResponseHandler,
//            eventMonitors: eventMonitors
//        )
//    }
// }
