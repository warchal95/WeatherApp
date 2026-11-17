import WeatherDomain

/// WMO weather interpretation codes, as documented by Open-Meteo.
enum WeatherConditionMapper {
    static func map(_ code: Int?) -> WeatherCondition {
        switch code {
        case 0: .clear
        case 1: .mainlyClear
        case 2: .partlyCloudy
        case 3: .overcast
        case 45, 48: .fog
        case 51, 53, 55: .drizzle
        case 56, 57: .freezingDrizzle
        case 61, 63, 65: .rain
        case 66, 67: .freezingRain
        case 71, 73, 75, 77: .snow
        case 80, 81, 82: .rainShowers
        case 85, 86: .snowShowers
        case 95, 96, 99: .thunderstorm
        default: .unknown
        }
    }
}
