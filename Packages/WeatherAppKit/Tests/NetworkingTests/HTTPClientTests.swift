import Foundation
import os
import Testing
@testable import Networking
import NetworkingTestSupport

struct HTTPClientTests {
    private struct Payload: Decodable, Equatable, Sendable {
        let name: String
    }

    private let host = "\(UUID().uuidString).test"

    private var endpoint: Endpoint {
        Endpoint(
            baseURL: URL(string: "https://\(host)")!,
            path: "v1/search",
            queryItems: [URLQueryItem(name: "name", value: "Bielsko-Biała")]
        )
    }

    private func makeSUT(handler: @escaping URLProtocolStub.Handler) -> HTTPClient {
        HTTPClient(session: URLProtocolStub.makeSession(host: host, handler: handler))
    }

    @Test
    func decodesSuccessfulResponse() async throws {
        // Arrange
        let sut = makeSUT { request in
            (.stub(url: request.url), Data(#"{"name":"Łódź"}"#.utf8))
        }

        // Act
        let payload = try await sut.get(endpoint, as: Payload.self)

        // Assert
        #expect(payload == Payload(name: "Łódź"))
    }

    @Test
    func sendsEndpointURLWithEncodedQuery() async throws {
        // Arrange
        let requestedURL = OSAllocatedUnfairLock<URL?>(initialState: nil)
        let sut = makeSUT { request in
            requestedURL.withLock { $0 = request.url }
            return (.stub(url: request.url), Data(#"{"name":"x"}"#.utf8))
        }

        // Act
        _ = try await sut.get(endpoint, as: Payload.self)

        // Assert
        #expect(requestedURL.withLock { $0 }?.absoluteString == "https://\(host)/v1/search?name=Bielsko-Bia%C5%82a")
    }

    @Test
    func throwsHTTPStatusWithBodyForNonSuccessCode() async {
        // Arrange
        let body = Data(#"{"error":true,"reason":"Invalid"}"#.utf8)
        let sut = makeSUT { request in
            (.stub(url: request.url, statusCode: 400), body)
        }

        // Act & Assert
        await #expect(throws: NetworkError.httpStatus(code: 400, body: body)) {
            try await sut.get(endpoint, as: Payload.self)
        }
    }

    @Test
    func throwsDecodingErrorForUnexpectedPayload() async {
        // Arrange
        let sut = makeSUT { request in
            (.stub(url: request.url), Data(#"{"unexpected":1}"#.utf8))
        }

        // Act
        let error = await #expect(throws: NetworkError.self) {
            try await sut.get(endpoint, as: Payload.self)
        }

        // Assert
        guard case .decoding = error else {
            Issue.record("Expected decoding error, got \(String(describing: error))")
            return
        }
    }

    @Test(arguments: [
        (URLError.Code.notConnectedToInternet, NetworkError.noConnection),
        (.networkConnectionLost, .noConnection),
        (.timedOut, .timedOut),
        (.cannotFindHost, .transport(.cannotFindHost))
    ])
    func mapsURLErrors(code: URLError.Code, expected: NetworkError) async {
        // Arrange
        let sut = makeSUT { _ in throw URLError(code) }

        // Act & Assert
        await #expect(throws: expected) {
            try await sut.get(endpoint, as: Payload.self)
        }
    }
}
