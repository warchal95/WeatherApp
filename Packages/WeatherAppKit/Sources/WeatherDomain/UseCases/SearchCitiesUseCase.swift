public protocol SearchCitiesUseCaseType: Sendable {
    func execute(_ query: String) async throws(DomainError) -> [City]
}

public struct SearchCitiesUseCase: SearchCitiesUseCaseType {
    /// Open-Meteo geocoding returns no results for single-character names.
    public static let minimumQueryLength = 2

    public typealias Dependencies = HasCityRepository
    private let dependencies: Dependencies
    private let validator: CityNameValidator

    public init(dependencies: Dependencies, validator: CityNameValidator = CityNameValidator()) {
        self.dependencies = dependencies
        self.validator = validator
    }

    public func execute(_ query: String) async throws(DomainError) -> [City] {
        guard validator.validate(query) == .valid else {
            throw .invalidQuery
        }
        let name = validator.normalize(query)
        guard name.count >= Self.minimumQueryLength else {
            return []
        }
        return try await dependencies.cityRepository.searchCities(named: name)
    }
}
