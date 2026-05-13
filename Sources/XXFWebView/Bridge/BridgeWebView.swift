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

    /// 发送自定义的事件 native->h5
    open func postEvent<Data: Encodable, ResponseData: Codable>(
        _ event: WebEventRequest<Data>,
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

    public typealias WebEventHandler = (
        WebEventRequest<AnyCodable>,
        @escaping (WebEventResponse<AnyCodable>) -> Void
    ) -> Void

    /// 用于接收自定义的事件 h5->native
    open var onWebEvent: WebEventHandler?

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

            guard let onWebEvent = self.onWebEvent else {
                callback(WebEventResponse.webviewOnWebEventNotSet())
                return
            }

            onWebEvent(event, callback)
        }), by: nil)
    }
}
