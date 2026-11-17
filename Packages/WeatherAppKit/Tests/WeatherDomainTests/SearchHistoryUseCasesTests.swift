import Testing
import WeatherDomain

struct SearchHistoryUseCasesTests {
    private let dependencies = DependenciesMock()
    private var repository: SearchHistoryRepositoryMock { dependencies.searchHistoryRepositoryMock }

    @Test
    func addingCityPutsItFirst() async throws {
        // Arrange
        repository.citiesResult = .success([.mock(id: 1), .mock(id: 2)])

        // Act
        let result = try await AddCityToSearchHistoryUseCase(dependencies: dependencies).execute(.mock(id: 3))

        // Assert
        #expect(result.map(\.id) == [3, 1, 2])
        #expect(repository.savedCities == [result])
    }

    @Test
    func addingCityAlreadyInHistoryMovesItToTopWithoutDuplicating() async throws {
        // Arrange
        repository.citiesResult = .success([.mock(id: 1), .mock(id: 2), .mock(id: 3)])

        // Act
        let result = try await AddCityToSearchHistoryUseCase(dependencies: dependencies).execute(.mock(id: 2))

        // Assert
        #expect(result.map(\.id) == [2, 1, 3])
    }

    @Test
    func addingCityKeepsHistoryWithinLimit() async throws {
        // Arrange
        let limit = AddCityToSearchHistoryUseCase.historyLimit
        repository.citiesResult = .success((1...limit).map { City.mock(id: $0) })

        // Act
        let result = try await AddCityToSearchHistoryUseCase(dependencies: dependencies).execute(.mock(id: 100))

        // Assert
        #expect(result.count == limit)
        #expect(result.first?.id == 100)
        #expect(!result.contains { $0.id == limit })
    }

    @Test
    func removingCityDropsOnlyThatCity() async throws {
        // Arrange
        repository.citiesResult = .success([.mock(id: 1), .mock(id: 2), .mock(id: 3)])

        // Act
        let result = try await RemoveCityFromSearchHistoryUseCase(dependencies: dependencies).execute(.mock(id: 2))

        // Assert
        #expect(result.map(\.id) == [1, 3])
        #expect(repository.savedCities == [result])
    }

    @Test
    func savingFailurePropagatesStorageError() async {
        // Arrange
        repository.saveError = .storage

        // Act & Assert
        await #expect(throws: DomainError.storage) {
            try await AddCityToSearchHistoryUseCase(dependencies: dependencies).execute(.mock())
        }
    }
}
