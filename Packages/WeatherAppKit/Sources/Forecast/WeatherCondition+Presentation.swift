import WeatherDomain

extension WeatherCondition {
    func symbolName(isDaytime: Bool) -> String {
        switch self {
        case .clear: isDaytime ? "sun.max.fill" : "moon.stars.fill"
        case .mainlyClear: isDaytime ? "sun.min.fill" : "moon.fill"
        case .partlyCloudy: isDaytime ? "cloud.sun.fill" : "cloud.moon.fill"
        case .overcast: "cloud.fill"
        case .fog: "cloud.fog.fill"
        case .drizzle: "cloud.drizzle.fill"
        case .freezingDrizzle, .freezingRain: "cloud.sleet.fill"
        case .rain: "cloud.rain.fill"
        case .rainShowers: "cloud.heavyrain.fill"
        case .snow, .snowShowers: "cloud.snow.fill"
        case .thunderstorm: "cloud.bolt.rain.fill"
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
