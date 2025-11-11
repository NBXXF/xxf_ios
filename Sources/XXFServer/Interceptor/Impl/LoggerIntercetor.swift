import Foundation
import Pulse

extension Request.Body {
    var asData: Data? {
        guard let buffer = data else { return nil }
        return buffer.getData(at: 0, length: buffer.readableBytes)
    }
}

open class LoggerIntercetor: Interceptor, @unchecked Sendable {
    /// 默认实例
    public static let shared = LoggerIntercetor()

    /// 是否启用日志记录，默认启用
    public var isLoggingEnabled: Bool

    public init(isLoggingEnabled: Bool = true) {
        self.isLoggingEnabled = isLoggingEnabled
    }

    open func willSend(request: Request) async throws -> Request {
        guard isLoggingEnabled else { return request } // 关闭日志则直接返回
        let requestID = UUID()
        PulseNetworkLoggerAdapter.shared.bind(id: requestID, to: request)

        let urlRequest = try makeURLRequest(from: request)

        let requestBody = request.body.asData

        PulseNetworkLoggerAdapter.shared.startLog(
            requestID: requestID,
            request: urlRequest,
            requestBody: requestBody
        )

        return request
    }

    open func didReceive(response: Response?, error: Error?, for request: Request) async throws -> Response {
        guard isLoggingEnabled else {
            if let response = response {
                return response
            } else if let error = error {
                throw error // 抛出错误，交给上层处理
            } else {
                return Response(status: .internalServerError) // 兜底
            }
        }

        guard let requestID = PulseNetworkLoggerAdapter.shared.requestID(for: request) else {
            if let response = response {
                return response
            } else if let error = error {
                throw error
            } else {
                return Response(status: .internalServerError)
            }
        }

        let httpResponse = response.flatMap { makeHTTPURLResponse(from: $0, originalRequest: request) }
        let responseData = response?.body.data

        PulseNetworkLoggerAdapter.shared.finishLog(
            requestID: requestID,
            response: httpResponse,
            responseBody: responseData,
            error: error
        )

        if let response = response {
            return response
        } else if let error = error {
            throw error
        } else {
            return Response(status: .internalServerError)
        }
    }

    public func makeURLRequest(from request: Request) throws -> URLRequest {
        guard let realURL = URL(string: request.url.string) else {
            throw Abort(.badRequest, reason: "Invalid URL")
        }

        var urlRequest = URLRequest(url: realURL)
        urlRequest.httpMethod = request.method.rawValue

        for (key, value) in request.headers {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if let data = request.body.asData {
            urlRequest.httpBody = data
        }

        return urlRequest
    }

    public func makeHTTPURLResponse(from response: Response, originalRequest: Request) -> HTTPURLResponse? {
        // 从请求中取 URL，防止 header 没有 x-original-url
        let url = URL(string: originalRequest.url.string) ?? URL(string: "http://localhost")!

        let headerDict = Dictionary(uniqueKeysWithValues: response.headers.map { ($0.name, $0.value) })

        return HTTPURLResponse(
            url: url,
            statusCode: Int(response.status.code),
            httpVersion: "HTTP/1.1",
            headerFields: headerDict
        )
    }
}
