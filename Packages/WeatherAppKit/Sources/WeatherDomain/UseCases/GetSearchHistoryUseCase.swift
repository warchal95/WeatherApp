public protocol GetSearchHistoryUseCaseType: Sendable {
    func execute() async throws(DomainError) -> [City]
}

public struct GetSearchHistoryUseCase: GetSearchHistoryUseCaseType {
    public typealias Dependencies = HasSearchHistoryRepository
    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    public func execute() async throws(DomainError) -> [City] {
        try await dependencies.searchHistoryRepository.cities()
    }
}
