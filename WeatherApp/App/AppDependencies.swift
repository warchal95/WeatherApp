import Foundation
import Networking
import WeatherData
import WeatherDomain

struct AppDependencies: HasCityRepository, HasForecastRepository, HasSearchHistoryRepository, HasNetworkMonitor {
    let cityRepository: CityRepositoryType
    let forecastRepository: ForecastRepositoryType
    let searchHistoryRepository: SearchHistoryRepositoryType
    let networkMonitor: NetworkMonitoring

    init(
        session: URLSession = .shared,
        userDefaults: UserDefaults = .standard,
        networkMonitor: NetworkMonitoring = NetworkMonitor(),
        languageCode: String = Bundle.main.preferredLocalizations.first ?? "en"
    ) {
        let httpClient = HTTPClient(session: session)
        let configuration = OpenMeteoConfiguration(languageCode: languageCode)
        cityRepository = CityRepository(httpClient: httpClient, configuration: configuration)
        forecastRepository = ForecastRepository(httpClient: httpClient, configuration: configuration)
        searchHistoryRepository = SearchHistoryRepository(userDefaults: userDefaults)
        self.networkMonitor = networkMonitor
    }
}
