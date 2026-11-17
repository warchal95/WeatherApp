import Foundation

public struct OpenMeteoConfiguration: Sendable {
    public static let defaultGeocodingBaseURL = URL(staticString: "https://geocoding-api.open-meteo.com")
    public static let defaultForecastBaseURL = URL(staticString: "https://api.open-meteo.com")

    public let geocodingBaseURL: URL
    public let forecastBaseURL: URL
    public let languageCode: String
    public let searchResultLimit: Int
    public let forecastDays: Int

    public init(
        geocodingBaseURL: URL = defaultGeocodingBaseURL,
        forecastBaseURL: URL = defaultForecastBaseURL,
        languageCode: String,
        searchResultLimit: Int = 20,
        forecastDays: Int = 7
    ) {
        self.geocodingBaseURL = geocodingBaseURL
        self.forecastBaseURL = forecastBaseURL
        self.languageCode = languageCode
        self.searchResultLimit = searchResultLimit
        self.forecastDays = forecastDays
    }
}

extension URL {
    init(staticString: StaticString) {
        guard let url = URL(string: "\(staticString)") else {
            preconditionFailure("Invalid URL literal: \(staticString)")
        }
        self = url
    }
}
