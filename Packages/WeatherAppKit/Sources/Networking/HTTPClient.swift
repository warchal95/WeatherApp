import Foundation

public protocol HTTPClientType: Sendable {
    func get<Response: Decodable & Sendable>(
        _ endpoint: Endpoint,
        as type: Response.Type
    ) async throws(NetworkError) -> Response
}

public struct HTTPClient: HTTPClientType {
    private let session: URLSession
    private let decoder: JSONDecoder

    public init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    public func get<Response: Decodable & Sendable>(
        _ endpoint: Endpoint,
        as type: Response.Type
    ) async throws(NetworkError) -> Response {
        let data = try await data(for: URLRequest(url: endpoint.url))
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw .decoding(description: String(describing: error))
        }
    }

    private func data(for request: URLRequest) async throws(NetworkError) -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            throw NetworkError(error)
        } catch is CancellationError {
            throw .cancelled
        } catch {
            throw .transport(.unknown)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw .httpStatus(code: httpResponse.statusCode, body: data)
        }
        return data
    }
}
