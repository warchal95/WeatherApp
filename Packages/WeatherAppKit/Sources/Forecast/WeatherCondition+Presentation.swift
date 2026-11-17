import WeatherDomain

extension WeatherCondition {
    /// Outline cloud variants: in multicolor mode the filled ones draw white clouds, invisible on a light background.
    func symbolName(isDaytime: Bool) -> String {
        switch self {
        case .clear: isDaytime ? "sun.max.fill" : "moon.stars.fill"
        case .mainlyClear: isDaytime ? "sun.min.fill" : "moon.fill"
        case .partlyCloudy: isDaytime ? "cloud.sun" : "cloud.moon"
        case .overcast: "cloud"
        case .fog: "cloud.fog"
        case .drizzle: "cloud.drizzle"
        case .freezingDrizzle, .freezingRain: "cloud.sleet"
        case .rain: "cloud.rain"
        case .rainShowers: "cloud.heavyrain"
        case .snow, .snowShowers: "cloud.snow"
        case .thunderstorm: "cloud.bolt.rain"
        case .unknown: "thermometer.medium"
        }
    }

    var localizedDescription: String {
        switch self {
        case .clear: String(localized: "Clear sky", bundle: .module)
        case .mainlyClear: String(localized: "Mainly clear", bundle: .module)
        case .partlyCloudy: String(localized: "Partly cloudy", bundle: .module)
        case .overcast: String(localized: "Overcast", bundle: .module)
        case .fog: String(localized: "Fog", bundle: .module)
        case .drizzle: String(localized: "Drizzle", bundle: .module)
        case .freezingDrizzle: String(localized: "Freezing drizzle", bundle: .module)
        case .rain: String(localized: "Rain", bundle: .module)
        case .freezingRain: String(localized: "Freezing rain", bundle: .module)
        case .snow: String(localized: "Snow", bundle: .module)
        case .rainShowers: String(localized: "Rain showers", bundle: .module)
        case .snowShowers: String(localized: "Snow showers", bundle: .module)
        case .thunderstorm: String(localized: "Thunderstorm", bundle: .module)
        case .unknown: String(localized: "No data", bundle: .module)
        }
    }
}
