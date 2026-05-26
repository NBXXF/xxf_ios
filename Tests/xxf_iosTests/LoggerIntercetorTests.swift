import Testing
@testable import XXFServer

@Test func duplicateResponseHeadersDoNotCrashLoggerInterceptor() async throws {
    let interceptor = LoggerIntercetor()
    var headers = HTTPHeaders()
    headers.add(name: "Set-Cookie", value: "a=1")
    headers.add(name: "Set-Cookie", value: "b=2")

    let headerFields = interceptor.makeHeaderFields(from: headers)

    #expect(headerFields["Set-Cookie"] == "a=1, b=2")
}
