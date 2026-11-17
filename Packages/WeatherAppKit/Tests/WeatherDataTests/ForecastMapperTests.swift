import Foundation
import Testing
import WeatherDomain
@testable import WeatherData

struct ForecastMapperTests {
    private func makeForecast() throws -> Forecast {
        try ForecastMapper.map(Fixtures.decode(Fixtures.forecast))
    }

    @Test
    func mapsCurrentConditions() throws {
        // Act
        let current = try makeForecast().current

        // Assert
        #expect(current.date == Date(timeIntervalSince1970: 1794910500))
        #expect(current.temperature == Measurement(value: 7.9, unit: .celsius))
        #expect(current.apparentTemperature == Measurement(value: 4.4, unit: .celsius))
        #expect(current.cloudCoverPercent == 100)
        #expect(current.condition == .drizzle)
        #expect(current.isDaytime)
    }

    @Test
    func takesPrecipitationProbabilityFromCurrentHour() throws {
        #expect(try makeForecast().current.precipitationProbabilityPercent == 63)
    }

    @Test
    func hourlyForecastStartsAtCurrentHourAndSkipsMissingTemperatures() throws {
        // Act
        let hourly = try makeForecast().hourly

        // Assert
        #expect(hourly.map(\.date.timeIntervalSince1970) == [1794909600, 1794916800])
        #expect(hourly.map(\.precipitationProbabilityPercent) == [63, nil])
        #expect(hourly.map(\.condition) == [.rain, .partlyCloudy])
        #expect(hourly.map(\.isDaytime) == [true, false])
    }

    @Test
    func dailyForecastSkipsDaysWithoutTemperatureRange() throws {
        // Act
        let daily = try makeForecast().daily

        // Assert
        #expect(daily.count == 1)
        #expect(daily.first?.minTemperature == Measurement(value: 5.8, unit: .celsius))
        #expect(daily.first?.maxTemperature == Measurement(value: 10.1, unit: .celsius))
        #expect(daily.first?.precipitationProbabilityPercent == 100)
    }

    @Test
    func usesLocationTimeZone() throws {
        #expect(try makeForecast().timeZone.identifier == "Europe/Warsaw")
    }
}
