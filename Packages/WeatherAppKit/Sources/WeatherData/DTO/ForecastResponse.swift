struct ForecastResponse: Decodable, Sendable {
    let timezone: String
    let utcOffsetSeconds: Int
    let current: Current
    let hourly: Hourly
    let daily: Daily

    struct Current: Decodable, Sendable {
        let time: Int
        let temperature: Double
        let apparentTemperature: Double?
        let cloudCover: Int
        let weatherCode: Int
        let isDay: Int

        enum CodingKeys: String, CodingKey {
            case time
            case temperature = "temperature_2m"
            case apparentTemperature = "apparent_temperature"
            case cloudCover = "cloud_cover"
            case weatherCode = "weather_code"
            case isDay = "is_day"
        }
    }

    struct Hourly: Decodable, Sendable {
        let time: [Int]
        let temperature: [Double?]
        let precipitationProbability: [Int?]
        let weatherCode: [Int?]
        let isDay: [Int?]

        enum CodingKeys: String, CodingKey {
            case time
            case temperature = "temperature_2m"
            case precipitationProbability = "precipitation_probability"
            case weatherCode = "weather_code"
            case isDay = "is_day"
        }
    }

    struct Daily: Decodable, Sendable {
        let time: [Int]
        let weatherCode: [Int?]
        let temperatureMax: [Double?]
        let temperatureMin: [Double?]
        let precipitationProbabilityMax: [Int?]

        enum CodingKeys: String, CodingKey {
            case time
            case weatherCode = "weather_code"
            case temperatureMax = "temperature_2m_max"
            case temperatureMin = "temperature_2m_min"
            case precipitationProbabilityMax = "precipitation_probability_max"
        }
    }

    enum CodingKeys: String, CodingKey {
        case timezone
        case utcOffsetSeconds = "utc_offset_seconds"
        case current, hourly, daily
    }
}
