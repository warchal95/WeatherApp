import CitySearch
import Forecast
import Networking
import WeatherDomain

@MainActor
final class AppCoordinator {
    typealias Dependencies = CitySearchViewFactory.Dependencies & ForecastViewFactory.Dependencies & HasNetworkMonitor

    let router: AppRouter
    let connectivityViewModel: ConnectivityViewModel
    private let citySearchViewFactory: CitySearchViewFactory
    private let forecastViewFactory: ForecastViewFactory

    private(set) lazy var rootView: CitySearchContainerView = citySearchViewFactory.makeCitySearchView { [weak self] action in
        self?.handle(action)
    }

    init(dependencies: Dependencies, router: AppRouter = AppRouter()) {
        self.router = router
        connectivityViewModel = ConnectivityViewModel(networkMonitor: dependencies.networkMonitor)
        citySearchViewFactory = CitySearchViewFactory(dependencies: dependencies)
        forecastViewFactory = ForecastViewFactory(dependencies: dependencies)
    }

    func view(for destination: AppRouter.Destination) -> ForecastContainerView {
        switch destination {
        case .forecast(let city):
            forecastViewFactory.makeForecastView(city: city)
        }
    }

    func handle(_ action: CitySearchViewModel.Action) {
        switch action {
        case .showForecast(let city):
            router.push(.forecast(city))
        }
    }
}
