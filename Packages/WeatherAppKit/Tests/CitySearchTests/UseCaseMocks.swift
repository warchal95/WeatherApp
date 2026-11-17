import WeatherDomain

final class SearchCitiesUseCaseMock: SearchCitiesUseCaseType, @unchecked Sendable {
    var executeResult: Result<[City], DomainError> = .success([.mock()])
    private(set) var receivedQueries: [String] = []

    func execute(_ query: String) async throws(DomainError) -> [City] {
        receivedQueries.append(query)
        return try executeResult.get()
    }
}

final class GetSearchHistoryUseCaseMock: GetSearchHistoryUseCaseType, @unchecked Sendable {
    var executeResult: Result<[City], DomainError> = .success([])

    func execute() async throws(DomainError) -> [City] {
        try executeResult.get()
    }
}

final class AddCityToSearchHistoryUseCaseMock: AddCityToSearchHistoryUseCaseType, @unchecked Sendable {
    var executeResult: Result<[City], DomainError> = .success([.mock()])
    private(set) var receivedCities: [City] = []

    func execute(_ city: City) async throws(DomainError) -> [City] {
        receivedCities.append(city)
        return try executeResult.get()
    }
}

final class RemoveCityFromSearchHistoryUseCaseMock: RemoveCityFromSearchHistoryUseCaseType, @unchecked Sendable {
    var executeResult: Result<[City], DomainError> = .success([])
    private(set) var receivedCities: [City] = []

    func execute(_ city: City) async throws(DomainError) -> [City] {
        receivedCities.append(city)
        return try executeResult.get()
    }
}

extension City {
    static func mock(id: Int = 1, name: String = "Kraków") -> City {
        City(id: id, name: name, region: "Małopolskie", country: "Polska", coordinates: Coordinates(latitude: 50.06, longitude: 19.94))
    }
}
