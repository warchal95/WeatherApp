import WeatherDomain

public struct CitySearchViewFactory {
    public typealias Dependencies = HasCityRepository & HasSearchHistoryRepository
    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    @MainActor
    public func makeCitySearchView(onAction: @escaping @MainActor (CitySearchViewModel.Action) -> Void) -> CitySearchContainerView {
        let viewModel = CitySearchViewModel(
            searchCities: SearchCitiesUseCase(dependencies: dependencies),
            getSearchHistory: GetSearchHistoryUseCase(dependencies: dependencies),
            addCityToSearchHistory: AddCityToSearchHistoryUseCase(dependencies: dependencies),
            removeCityFromSearchHistory: RemoveCityFromSearchHistoryUseCase(dependencies: dependencies)
        )
        viewModel.onAction = onAction
        return CitySearchContainerView(viewModel: viewModel)
    }
}
