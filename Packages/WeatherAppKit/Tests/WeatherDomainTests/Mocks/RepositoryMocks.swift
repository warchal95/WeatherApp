import WeatherDomain

final class CityRepositoryMock: CityRepositoryType, @unchecked Sendable {
    var searchCitiesResult: Result<[City], DomainError> = .success([.mock()])
    private(set) var searchCitiesCallCount = 0
    private(set) var lastSearchedName: String?

    func searchCities(named name: String) async throws(DomainError) -> [City] {
        searchCitiesCallCount += 1
        lastSearchedName = name
        return try searchCitiesResult.get()
    }
}

final class SearchHistoryRepositoryMock: SearchHistoryRepositoryType, @unchecked Sendable {
    var citiesResult: Result<[City], DomainError> = .success([])
    var saveError: DomainError?
    private(set) var savedCities: [[City]] = []

    func cities() async throws(DomainError) -> [City] {
        try citiesResult.get()
    }

    func save(_ cities: [City]) async throws(DomainError) {
        if let saveError { throw saveError }
        savedCities.append(cities)
    }
}

struct DependenciesMock: HasCityRepository, HasSearchHistoryRepository {
    var cityRepository: CityRepositoryType { cityRepositoryMock }
    var searchHistoryRepository: SearchHistoryRepositoryType { searchHistoryRepositoryMock }

    let cityRepositoryMock = CityRepositoryMock()
    let searchHistoryRepositoryMock = SearchHistoryRepositoryMock()
}

extension City {
    static func mock(id: Int = 1, name: String = "Kraków") -> City {
        City(id: id, name: name, region: "Małopolskie", country: "Polska", coordinates: Coordinates(latitude: 50.06, longitude: 19.94))
    }
}
