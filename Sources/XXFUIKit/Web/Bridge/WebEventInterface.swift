//
//  WebEventInterface.swift
//  xxf_ios
//

import DSBridge
import Foundation
import XXFJson

private final class WebEventInterface: ExposedInterface {
    private static let methodName = "handleWebEvent"

    fileprivate typealias Handler = (
        WebEventRequest<AnyCodable>,
        @escaping (WebEventResponse<AnyCodable>) -> Void
    ) -> Void

    private let handler: Handler

    fileprivate init(handler: @escaping Handler) {
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
                completion(try makeBridgeJSONObject(from: response), true)
            } catch {
                completion([
                    "code": -1,
                    "message": error.localizedDescription,
                    "data": NSNull()
                ], true)
            }
        }
    }

    private static func makeRequest(from parameter: Any?) -> WebEventRequest<AnyCodable>? {
        do {
            let data = try makeBridgeJSONData(from: parameter)
            return try Foundation.JSONDecoder().decode(
                WebEventRequest<AnyCodable>.self,
                from: data
            )
        } catch {
            return nil
        }
    }
}
