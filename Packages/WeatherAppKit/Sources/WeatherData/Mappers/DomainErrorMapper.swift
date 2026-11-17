import Foundation
import Networking
import WeatherDomain

enum DomainErrorMapper {
    static func map(_ error: NetworkError, decoder: JSONDecoder = JSONDecoder()) -> DomainError {
        switch error {
        case .noConnection, .timedOut:
            .noConnection
        case .transport(let code) where unreachableHostCodes.contains(code):
            .noConnection
        case .cancelled:
            .cancelled
        case .httpStatus(_, let body):
            .server(message: try? decoder.decode(OpenMeteoErrorResponse.self, from: body).reason)
        case .transport:
            .server(message: nil)
        case .invalidResponse, .decoding:
            .invalidResponse
        }
    }

    private static let unreachableHostCodes: Set<URLError.Code> = [.cannotFindHost, .cannotConnectToHost, .dnsLookupFailed]
}
