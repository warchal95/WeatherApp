import Foundation
import Networking
import WeatherData
import WeatherDomain

struct AppDependencies: HasCityRepository, HasForecastRepository, HasSearchHistoryRepository {
    let cityRepository: CityRepositoryType
    let forecastRepository: ForecastRepositoryType
    let searchHistoryRepository: SearchHistoryRepositoryType

    init(
        session: URLSession = .shared,
        userDefaults: UserDefaults = .standard,
        languageCode: String = Bundle.main.preferredLocalizations.first ?? "en"
    ) {
        let httpClient = HTTPClient(session: session)
        let configuration = OpenMeteoConfiguration(languageCode: languageCode)
        cityRepository = CityRepository(httpClient: httpClient, configuration: configuration)
        forecastRepository = ForecastRepository(httpClient: httpClient, configuration: configuration)
        searchHistoryRepository = SearchHistoryRepository(userDefaults: userDefaults)
    }
}
