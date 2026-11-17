import Testing
import WeatherDomain

struct SearchCitiesUseCaseTests {
    private let dependencies = DependenciesMock()

    private var sut: SearchCitiesUseCase {
        SearchCitiesUseCase(dependencies: dependencies)
    }

    @Test
    func searchesRepositoryWithNormalizedName() async throws {
        // Arrange
        let cities = [City.mock(id: 1, name: "Nowy Sącz")]
        dependencies.cityRepositoryMock.searchCitiesResult = .success(cities)

        // Act
        let result = try await sut.execute("  Nowy   Sącz ")

        // Assert
        #expect(result == cities)
        #expect(dependencies.cityRepositoryMock.lastSearchedName == "Nowy Sącz")
    }

    @Test
    func returnsNoCitiesForQueryShorterThanMinimumWithoutSearching() async throws {
        // Act
        let result = try await sut.execute("W")

        // Assert
        #expect(result.isEmpty)
        #expect(dependencies.cityRepositoryMock.searchCitiesCallCount == 0)
    }

    @Test(arguments: ["", "Kraków2", "War$zawa"])
    func throwsInvalidQueryWithoutSearching(query: String) async {
        // Act & Assert
        await #expect(throws: DomainError.invalidQuery) {
            try await sut.execute(query)
        }
        #expect(dependencies.cityRepositoryMock.searchCitiesCallCount == 0)
    }

    @Test
    func propagatesRepositoryError() async {
        // Arrange
        dependencies.cityRepositoryMock.searchCitiesResult = .failure(.noConnection)

        // Act & Assert
        await #expect(throws: DomainError.noConnection) {
            try await sut.execute("Gdańsk")
        }
    }
}
