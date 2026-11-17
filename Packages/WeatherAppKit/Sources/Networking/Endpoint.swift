import Foundation

public struct Endpoint: Equatable, Sendable {
    public let baseURL: URL
    public let path: String
    public let queryItems: [URLQueryItem]

    public init(baseURL: URL, path: String, queryItems: [URLQueryItem] = []) {
        self.baseURL = baseURL
        self.path = path
        self.queryItems = queryItems
    }

    public var url: URL {
        let url = baseURL.appending(path: path)
        guard !queryItems.isEmpty else { return url }
        return url.appending(queryItems: queryItems)
    }
}
