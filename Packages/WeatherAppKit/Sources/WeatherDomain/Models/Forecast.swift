import Foundation

public struct Forecast: Equatable, Sendable {
    public let timeZone: TimeZone
    public let current: CurrentConditions
    public let hourly: [HourlyForecast]
    public let daily: [DailyForecast]

    public init(timeZone: TimeZone, current: CurrentConditions, hourly: [HourlyForecast], daily: [DailyForecast]) {
        self.timeZone = timeZone
        self.current = current
        self.hourly = hourly
        self.daily = daily
    }
}

public struct CurrentConditions: Equatable, Sendable {
    public let date: Date
    public let temperature: Measurement<UnitTemperature>
    public let apparentTemperature: Measurement<UnitTemperature>?
    public let cloudCoverPercent: Int
    public let precipitationProbabilityPercent: Int?
    public let condition: WeatherCondition
    public let isDaytime: Bool

    public init(
        date: Date,
        temperature: Measurement<UnitTemperature>,
        apparentTemperature: Measurement<UnitTemperature>?,
        cloudCoverPercent: Int,
        precipitationProbabilityPercent: Int?,
        condition: WeatherCondition,
        isDaytime: Bool
    ) {
        self.date = date
        self.temperature = temperature
        self.apparentTemperature = apparentTemperature
        self.cloudCoverPercent = cloudCoverPercent
        self.precipitationProbabilityPercent = precipitationProbabilityPercent
        self.condition = condition
        self.isDaytime = isDaytime
    }
}

public struct HourlyForecast: Identifiable, Equatable, Sendable {
    public var id: Date { date }
    public let date: Date
    public let temperature: Measurement<UnitTemperature>
    public let precipitationProbabilityPercent: Int?
    public let condition: WeatherCondition
    public let isDaytime: Bool

    public init(
        date: Date,
        temperature: Measurement<UnitTemperature>,
        precipitationProbabilityPercent: Int?,
        condition: WeatherCondition,
        isDaytime: Bool
    ) {
        self.date = date
        self.temperature = temperature
        self.precipitationProbabilityPercent = precipitationProbabilityPercent
        self.condition = condition
        self.isDaytime = isDaytime
    }
}

public struct DailyForecast: Identifiable, Equatable, Sendable {
    public var id: Date { date }
    public let date: Date
    public let minTemperature: Measurement<UnitTemperature>
    public let maxTemperature: Measurement<UnitTemperature>
    public let precipitationProbabilityPercent: Int?
    public let condition: WeatherCondition

    public init(
        date: Date,
        minTemperature: Measurement<UnitTemperature>,
        maxTemperature: Measurement<UnitTemperature>,
        precipitationProbabilityPercent: Int?,
        condition: WeatherCondition
    ) {
        self.date = date
        self.minTemperature = minTemperature
        self.maxTemperature = maxTemperature
        self.precipitationProbabilityPercent = precipitationProbabilityPercent
        self.condition = condition
    }
}
