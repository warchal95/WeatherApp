public enum DomainError: Error, Equatable, Sendable {
    case invalidQuery
    case noConnection
    case cancelled
    case server(message: String?)
    case invalidResponse
    case storage
}
