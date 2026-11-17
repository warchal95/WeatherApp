import Foundation
import Testing
import WeatherDomain
@testable import WeatherData

struct SearchHistoryRepositoryTests {
    private let suiteName = UUID().uuidString
    private let userDefaults: UserDefaults

    init() throws {
        userDefaults = try #require(UserDefaults(suiteName: suiteName))
    }

    private let cities = [
        City(id: 1, name: "Bielsko-Biała", region: "Województwo śląskie", country: "Polska", coordinates: Coordinates(latitude: 49.8, longitude: 19.0)),
        City(id: 2, name: "Nowy Sącz", region: nil, country: nil, coordinates: Coordinates(latitude: 49.6, longitude: 20.7))
    ]

    @Test
    func returnsEmptyHistoryWhenNothingWasSaved() async throws {
        #expect(try await SearchHistoryRepository(userDefaults: userDefaults).cities().isEmpty)
    }

    @Test
    func persistsCitiesAcrossInstances() async throws {
        // Arrange
        try await SearchHistoryRepository(userDefaults: userDefaults).save(cities)

        // Act
        let restored = try await SearchHistoryRepository(userDefaults: userDefaults).cities()

        // Assert
        #expect(restored == cities)
    }

    @Test
    func throwsStorageErrorForCorruptedData() async {
        // Arrange
        userDefaults.set(Data("not json".utf8), forKey: "searchHistory.v1")

        // Act & Assert
        await #expect(throws: DomainError.storage) {
            try await SearchHistoryRepository(userDefaults: userDefaults).cities()
        }
    }
}
