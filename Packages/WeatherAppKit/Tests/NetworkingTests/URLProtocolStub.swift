import Foundation
import os

final class URLProtocolStub: URLProtocol {
    typealias Handler = @Sendable (URLRequest) throws -> (HTTPURLResponse, Data)

    private static let handlers = OSAllocatedUnfairLock<[String: Handler]>(initialState: [:])

    /// Handlers are keyed by host so tests running in parallel never see each other's stubs.
    static func makeSession(host: String, handler: @escaping Handler) -> URLSession {
        handlers.withLock { $0[host] = handler }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let host = request.url?.host() ?? ""
        guard let handler = Self.handlers.withLock({ $0[host] }) else {
            client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

extension HTTPURLResponse {
    static func stub(url: URL?, statusCode: Int = 200) -> HTTPURLResponse {
        HTTPURLResponse(url: url ?? URL(fileURLWithPath: "/"), statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
}
