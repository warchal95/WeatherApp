public protocol CityRepositoryType: Sendable {
    func searchCities(named name: String) async throws(DomainError) -> [City]
}

public protocol ForecastRepositoryType: Sendable {
    func forecast(at coordinates: Coordinates) async throws(DomainError) -> Forecast
}

public protocol SearchHistoryRepositoryType: Sendable {
    func cities() async throws(DomainError) -> [City]
    func save(_ cities: [City]) async throws(DomainError)
}

public protocol HasCityRepository: Sendable {
    var cityRepository: CityRepositoryType { get }
}

public protocol HasForecastRepository: Sendable {
    var forecastRepository: ForecastRepositoryType { get }
}

public protocol HasSearchHistoryRepository: Sendable {
    var searchHistoryRepository: SearchHistoryRepositoryType { get }
}
