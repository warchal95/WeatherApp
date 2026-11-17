public protocol AddCityToSearchHistoryUseCaseType: Sendable {
    @discardableResult
    func execute(_ city: City) async throws(DomainError) -> [City]
}

public struct AddCityToSearchHistoryUseCase: AddCityToSearchHistoryUseCaseType {
    public static let historyLimit = 10

    public typealias Dependencies = HasSearchHistoryRepository
    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    @discardableResult
    public func execute(_ city: City) async throws(DomainError) -> [City] {
        let repository = dependencies.searchHistoryRepository
        let others = try await repository.cities().filter { $0.id != city.id }
        let updated = Array(([city] + others).prefix(Self.historyLimit))
        try await repository.save(updated)
        return updated
    }
}
