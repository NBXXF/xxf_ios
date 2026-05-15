//
//  BridgeWebView.swift
//  xxf_ios
//  jsbrige 通用方法封装
//  Created by xxf on 5/13.
//

import DSBridge
import Foundation
import WebKit
import XXFJson

open class BridgeWebView: DSBridge.WebView {
    private static let webBridgeNativeEventMethodName = "nativeEvent"
    public enum LogLevel: String {
        case info
        case warning
        case error
    }

    public typealias Printer = (_ level: LogLevel, _ message: String) -> Void
    private let printerLock = NSLock()
    private var _printer: Printer?

    open var printer: Printer? {
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

    /// 发送自定义的事件 native->h5
    open func postEvent<RequestData: Codable, ResponseData: Codable>(
        _ event: WebEventRequest<RequestData>,
        expecting responseType: WebEventResponse<ResponseData>.Type,
        completion: @escaping (Result<WebEventResponse<ResponseData>, any Swift.Error>) -> Void
    ) {
        do {
            let payload = try BridgePayloadCodec.makeJSONObject(from: event)
            call(Self.webBridgeNativeEventMethodName, with: [payload]) { result in
                do {
                    let response: WebEventResponse<ResponseData> = try BridgePayloadCodec.decodeJSON(
                        result,
                        as: responseType
                    )
                    completion(.success(response))
                } catch {
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }

    /// 发送自定义的事件 native->h5（便捷方法：直接传 eventName 和 data）
    open func postEvent<RequestData: Codable, ResponseData: Codable>(
        eventName: String,
        data: RequestData? = nil,
        expecting responseType: WebEventResponse<ResponseData>.Type,
        completion: @escaping (Result<WebEventResponse<ResponseData>, any Swift.Error>) -> Void
    ) {
        let event = WebEventRequest(event: eventName, data: data)
        postEvent(event, expecting: responseType, completion: completion)
    }

    public typealias WebEventHandling = (
        WebEventRequest<AnyCodable>,
        @escaping (WebEventResponse<AnyCodable>) -> Void
    ) -> Void

    /// 用于接收自定义的事件 h5->native, 优先级高于eventHandlerRegistry
    open var onWebEvent: WebEventHandling?
    /// 兼容以前的设计分发
    open var eventHandlerRegistry: WebEventHandlerRegistry?

    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setupWebEventInterface()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWebEventInterface()
    }

    private func setupWebEventInterface() {
        addInterface(WebEventInterface(handler: { [weak self] event, callback in
            guard let self else {
                callback(WebEventResponse.webviewReleased())
                return
            }

            if let onWebEvent = self.onWebEvent {
                onWebEvent(event, callback)
            } else if let eventHandlerRegistry = self.eventHandlerRegistry {
                eventHandlerRegistry.dispatch(event: event, completion: callback)
            } else {
                callback(WebEventResponse.webviewOnWebEventNotSet())
            }
        }), by: nil)
    }

    /// 打印注册的webviewEvent
    private func debugLogRegisteredEvents(action: String) {
        let eventNames = eventHandlerRegistry?.registeredEventNames ?? []
        emitLog(.info, "\(action) registryWebEvents(\(eventNames.count)): \(eventNames)")
    }

    override open func load(_ request: URLRequest) -> WKNavigation? {
        debugLogRegisteredEvents(action: "load")
        return super.load(request)
    }

    override open func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        debugLogRegisteredEvents(action: "loadHTMLString")
        return super.loadHTMLString(string, baseURL: baseURL)
    }

    override open func loadFileURL(_ URL: URL, allowingReadAccessTo readAccessURL: URL) -> WKNavigation? {
        debugLogRegisteredEvents(action: "loadFileURL")
        return super.loadFileURL(URL, allowingReadAccessTo: readAccessURL)
    }

    override open func reload() -> WKNavigation? {
        debugLogRegisteredEvents(action: "reload")
        return super.reload()
    }

    override open func reloadFromOrigin() -> WKNavigation? {
        debugLogRegisteredEvents(action: "reloadFromOrigin")
        return super.reloadFromOrigin()
    }

    private func emitLog(_ level: LogLevel, _ message: String) {
        printerLock.lock()
        let printer = _printer
        printerLock.unlock()
        printer?(level, message)
    }
}
