import Foundation
import WeatherDomain

enum ForecastMapper {
    private static let hour: TimeInterval = 3600

    static func map(_ response: ForecastResponse) throws(DomainError) -> Forecast {
        guard let timeZone = TimeZone(identifier: response.timezone)
            ?? TimeZone(secondsFromGMT: response.utcOffsetSeconds) else {
            throw .invalidResponse
        }
        let currentDate = Date(timeIntervalSince1970: TimeInterval(response.current.time))
        let hourly = mapHourly(response.hourly)
        let currentHour = hourly.first { $0.date <= currentDate && currentDate < $0.date.addingTimeInterval(hour) }

        return Forecast(
            timeZone: timeZone,
            current: CurrentConditions(
                date: currentDate,
                temperature: .celsius(response.current.temperature),
                apparentTemperature: response.current.apparentTemperature.map(Measurement.celsius),
                cloudCoverPercent: response.current.cloudCover,
                precipitationProbabilityPercent: currentHour?.precipitationProbabilityPercent,
                condition: WeatherConditionMapper.map(response.current.weatherCode),
                isDaytime: response.current.isDay == 1
            ),
            hourly: hourly.filter { $0.date.addingTimeInterval(hour) > currentDate },
            daily: mapDaily(response.daily)
        )
    }

    private static func mapHourly(_ hourly: ForecastResponse.Hourly) -> [HourlyForecast] {
        hourly.time.indices.compactMap { index in
            guard let temperature = hourly.temperature[safe: index] ?? nil else { return nil }
            return HourlyForecast(
                date: Date(timeIntervalSince1970: TimeInterval(hourly.time[index])),
                temperature: .celsius(temperature),
                precipitationProbabilityPercent: hourly.precipitationProbability[safe: index] ?? nil,
                condition: WeatherConditionMapper.map(hourly.weatherCode[safe: index] ?? nil),
                isDaytime: (hourly.isDay[safe: index] ?? nil) != 0
            )
        }
    }

    private static func mapDaily(_ daily: ForecastResponse.Daily) -> [DailyForecast] {
        daily.time.indices.compactMap { index in
            guard let min = daily.temperatureMin[safe: index] ?? nil,
                  let max = daily.temperatureMax[safe: index] ?? nil else { return nil }
            return DailyForecast(
                date: Date(timeIntervalSince1970: TimeInterval(daily.time[index])),
                minTemperature: .celsius(min),
                maxTemperature: .celsius(max),
                precipitationProbabilityPercent: daily.precipitationProbabilityMax[safe: index] ?? nil,
                condition: WeatherConditionMapper.map(daily.weatherCode[safe: index] ?? nil)
            )
        }
    }
}

private extension Measurement where UnitType == UnitTemperature {
    static func celsius(_ value: Double) -> Self {
        Measurement(value: value, unit: .celsius)
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
