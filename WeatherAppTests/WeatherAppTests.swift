import CitySearch
import Networking
import Testing
import WeatherDomain
@testable import WeatherApp

@MainActor
struct AppCoordinatorTests {
    private let city = City(id: 1, name: "Nowy Sącz", region: nil, country: "Polska", coordinates: Coordinates(latitude: 49.62, longitude: 20.69))

    @Test
    func showForecastActionPushesForecastDestination() {
        // Arrange
        let router = AppRouter()
        let sut = AppCoordinator(dependencies: DependenciesStub(), router: router)

        // Act
        sut.handle(.showForecast(city))

        // Assert
        #expect(router.path == [.forecast(city)])
    }

    @Test
    func popReturnsToSearch() {
        // Arrange
        let router = AppRouter()
        router.push(.forecast(city))

        // Act
        router.pop()

        // Assert
        #expect(router.path.isEmpty)
    }
}

private struct DependenciesStub: HasCityRepository, HasForecastRepository, HasSearchHistoryRepository, HasNetworkMonitor {
    let cityRepository: CityRepositoryType = RepositoryStub()
    let forecastRepository: ForecastRepositoryType = RepositoryStub()
    let searchHistoryRepository: SearchHistoryRepositoryType = RepositoryStub()
    let networkMonitor: NetworkMonitoring = NetworkMonitorMock()
}

private struct RepositoryStub: CityRepositoryType, ForecastRepositoryType, SearchHistoryRepositoryType {
    func searchCities(named name: String) async throws(DomainError) -> [City] { [] }
    func forecast(at coordinates: Coordinates) async throws(DomainError) -> Forecast { throw .invalidResponse }
    func cities() async throws(DomainError) -> [City] { [] }
    func save(_ cities: [City]) async throws(DomainError) {}
}
