public protocol GetForecastUseCaseType: Sendable {
    func execute(_ city: City) async throws(DomainError) -> Forecast
}

public struct GetForecastUseCase: GetForecastUseCaseType {
    public typealias Dependencies = HasForecastRepository
    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    public func execute(_ city: City) async throws(DomainError) -> Forecast {
        try await dependencies.forecastRepository.forecast(at: city.coordinates)
    }
}
