import WeatherDomain

public struct ForecastViewFactory {
    public typealias Dependencies = HasForecastRepository
    private let dependencies: Dependencies

    public init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    @MainActor
    public func makeForecastView(city: City) -> ForecastContainerView {
        ForecastContainerView(
            viewModel: ForecastViewModel(city: city, getForecast: GetForecastUseCase(dependencies: dependencies))
        )
    }
}
