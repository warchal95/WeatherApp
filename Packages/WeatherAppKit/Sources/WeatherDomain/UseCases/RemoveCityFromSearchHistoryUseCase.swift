public protocol RemoveCityFromSearchHistoryUseCaseType: Sendable {
    @discardableResult
    func execute(_ city: City) async throws(DomainError) -> [City]
}

public struct RemoveCityFromSearchHistoryUseCase: RemoveCityFromSearchHistoryUseCaseType {
    public typealias Dependencies = HasSearchHistoryRepository
    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    @discardableResult
    public func execute(_ city: City) async throws(DomainError) -> [City] {
        let repository = dependencies.searchHistoryRepository
        let updated = try await repository.cities().filter { $0.id != city.id }
        try await repository.save(updated)
        return updated
    }
}
