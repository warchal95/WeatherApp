import Foundation

public enum NetworkError: Error, Equatable, Sendable {
    case noConnection
    case timedOut
    case cancelled
    case transport(URLError.Code)
    case invalidResponse
    case httpStatus(code: Int, body: Data)
    case decoding(description: String)
}

extension NetworkError {
    init(_ urlError: URLError) {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed, .internationalRoamingOff:
            self = .noConnection
        case .timedOut:
            self = .timedOut
        case .cancelled:
            self = .cancelled
        default:
            self = .transport(urlError.code)
        }
    }
}
