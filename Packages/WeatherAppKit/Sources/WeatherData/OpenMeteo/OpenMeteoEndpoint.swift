import Foundation
import Networking
import WeatherDomain

enum OpenMeteoEndpoint {
    static func search(name: String, configuration: OpenMeteoConfiguration) -> Endpoint {
        Endpoint(
            baseURL: configuration.geocodingBaseURL,
            path: "v1/search",
            queryItems: [
                URLQueryItem(name: "name", value: name),
                URLQueryItem(name: "count", value: String(configuration.searchResultLimit)),
                URLQueryItem(name: "language", value: configuration.languageCode),
                URLQueryItem(name: "format", value: "json")
            ]
        )
    }

    static func forecast(at coordinates: Coordinates, configuration: OpenMeteoConfiguration) -> Endpoint {
        Endpoint(
            baseURL: configuration.forecastBaseURL,
            path: "v1/forecast",
            queryItems: [
                URLQueryItem(name: "latitude", value: String(coordinates.latitude)),
                URLQueryItem(name: "longitude", value: String(coordinates.longitude)),
                URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,cloud_cover,weather_code,is_day"),
                URLQueryItem(name: "hourly", value: "temperature_2m,precipitation_probability,weather_code,is_day"),
                URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max"),
                URLQueryItem(name: "timezone", value: "auto"),
                URLQueryItem(name: "timeformat", value: "unixtime"),
                URLQueryItem(name: "forecast_days", value: String(configuration.forecastDays))
            ]
        )
    }
}
