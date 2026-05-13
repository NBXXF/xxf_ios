//
//  WebEventInterface.swift
//  xxf_ios
//

import DSBridge
import Foundation
import XXFJson

final class WebEventInterface: ExposedInterface {
    private static let methodName = "handleWebEvent"

    typealias Handler = (
        WebEventRequest<AnyCodable>,
        @escaping (WebEventResponse<AnyCodable>) -> Void
    ) -> Void

    private let handler: Handler

    init(handler: @escaping Handler) {
        self.handler = handler
    }

    func hasMethod(named name: String, isSynchronous: Bool?) -> Bool {
        name == Self.methodName && isSynchronous != true
    }

    func handle(calling methodName: String, with parameter: Any?) -> Any? {
        nil
    }

    func handle(
        calling methodName: String,
        with parameter: Any?,
        completion: @escaping (Any?, Bool) -> Void
    ) {
        guard methodName == Self.methodName else {
            completion(nil, true)
            return
        }
        guard let event = Self.makeRequest(from: parameter) else {
            completion(nil, true)
            return
        }
        handler(event) { response in
            do {
                completion(try BridgePayloadCodec.makeJSONObject(from: response), true)
            } catch {
                let failResponse = WebEventResponse<AnyCodable>.fail(
                    data: AnyCodable(NSNull()),
                    message: error.localizedDescription,
                    code: -1
                )
                completion(try? BridgePayloadCodec.makeJSONObject(from: failResponse), true)
            }
        }
    }

    private static func makeRequest(from parameter: Any?) -> WebEventRequest<AnyCodable>? {
        do {
            let data = try BridgePayloadCodec.makeJSONData(from: parameter)
            return try JSON.fromJson(data)
        } catch {
            return nil
        }
    }
}
