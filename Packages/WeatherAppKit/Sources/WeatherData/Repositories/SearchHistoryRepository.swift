import Foundation
import WeatherDomain

public struct SearchHistoryRepository: SearchHistoryRepositoryType {
    // UserDefaults is documented as thread-safe but is not annotated Sendable in the SDK.
    nonisolated(unsafe) private let userDefaults: UserDefaults
    private let key: String

    public init(userDefaults: UserDefaults, key: String = "searchHistory.v1") {
        self.userDefaults = userDefaults
        self.key = key
    }

    public func cities() async throws(DomainError) -> [City] {
        guard let data = userDefaults.data(forKey: key) else { return [] }
        do {
            return try JSONDecoder().decode([StoredCity].self, from: data).map(\.city)
        } catch {
            throw .storage
        }
    }

    public func save(_ cities: [City]) async throws(DomainError) {
        do {
            userDefaults.set(try JSONEncoder().encode(cities.map(StoredCity.init)), forKey: key)
        } catch {
            throw .storage
        }
    }
}
