import Foundation
import Testing
import WeatherDomain
@testable import Forecast

@MainActor
struct ForecastViewModelTests {
    private let getForecast = GetForecastUseCaseMock()
    private let city = City(id: 1, name: "Łódź", region: nil, country: "Polska", coordinates: Coordinates(latitude: 51.77, longitude: 19.46))

    private func makeSUT() -> ForecastViewModel {
        ForecastViewModel(city: city, getForecast: getForecast)
    }

    @Test
    func onLoadShowsForecastForCity() async {
        // Arrange
        let sut = makeSUT()

        // Act
        await sut.onLoad()

        // Assert
        #expect(sut.state == .loaded(.mock()))
        #expect(getForecast.receivedCities == [city])
    }

    @Test
    func onLoadLimitsHourlyForecastToNext24Hours() async throws {
        // Arrange
        getForecast.executeResult = .success(.mock(hourCount: 48))
        let sut = makeSUT()

        // Act
        await sut.onLoad()

        // Assert
        guard case .loaded(let forecast) = sut.state else {
            Issue.record("Expected loaded state, got \(sut.state)")
            return
        }
        #expect(forecast.hourly.count == ForecastViewModel.hourlyForecastLength)
    }

    @Test
    func onLoadShowsErrorWhenRequestFails() async {
        // Arrange
        getForecast.executeResult = .failure(.server(message: "Invalid coordinates"))
        let sut = makeSUT()

        // Act
        await sut.onLoad()

        // Assert
        #expect(sut.state == .failed(.server(message: "Invalid coordinates")))
    }

    @Test
    func onLoadDoesNotReloadLoadedForecast() async {
        // Arrange
        let sut = makeSUT()
        await sut.onLoad()

        // Act
        await sut.onLoad()

        // Assert
        #expect(getForecast.receivedCities.count == 1)
    }

    @Test
    func retryAfterFailureLoadsForecast() async {
        // Arrange
        getForecast.executeResult = .failure(.noConnection)
        let sut = makeSUT()
        await sut.onLoad()
        getForecast.executeResult = .success(.mock())

        // Act
        await sut.didTapRetry()

        // Assert
        #expect(sut.state == .loaded(.mock()))
    }

    @Test
    func failedRefreshKeepsForecastAndReportsError() async {
        // Arrange
        let sut = makeSUT()
        await sut.onLoad()
        getForecast.executeResult = .failure(.noConnection)

        // Act
        await sut.didPullToRefresh()

        // Assert
        #expect(sut.state == .loaded(.mock()))
        #expect(sut.refreshError == .noConnection)
    }

    @Test
    func successfulRefreshClearsPreviousRefreshError() async {
        // Arrange
        let sut = makeSUT()
        await sut.onLoad()
        getForecast.executeResult = .failure(.noConnection)
        await sut.didPullToRefresh()
        getForecast.executeResult = .success(.mock(hourCount: 2))

        // Act
        await sut.didPullToRefresh()

        // Assert
        #expect(sut.state == .loaded(.mock(hourCount: 2)))
        #expect(sut.refreshError == nil)
    }

    @Test
    func cancelledRequestKeepsCurrentState() async {
        // Arrange
        getForecast.executeResult = .failure(.cancelled)
        let sut = makeSUT()

        // Act
        await sut.onLoad()

        // Assert
        #expect(sut.state == .loading)
    }
}

final class GetForecastUseCaseMock: GetForecastUseCaseType, @unchecked Sendable {
    var executeResult: Result<Forecast, DomainError> = .success(.mock())
    private(set) var receivedCities: [City] = []

    func execute(_ city: City) async throws(DomainError) -> Forecast {
        receivedCities.append(city)
        return try executeResult.get()
    }
}

extension Forecast {
    static func mock(hourCount: Int = 3) -> Forecast {
        let start = Date(timeIntervalSince1970: 1_794_909_600)
        return Forecast(
            timeZone: TimeZone(identifier: "Europe/Warsaw") ?? .current,
            current: CurrentConditions(
                date: start,
                temperature: Measurement(value: 7.9, unit: .celsius),
                apparentTemperature: Measurement(value: 4.4, unit: .celsius),
                cloudCoverPercent: 100,
                precipitationProbabilityPercent: 63,
                condition: .drizzle,
                isDaytime: true
            ),
            hourly: (0..<hourCount).map { hour in
                HourlyForecast(
                    date: start.addingTimeInterval(TimeInterval(hour) * 3600),
                    temperature: Measurement(value: 8, unit: .celsius),
                    precipitationProbabilityPercent: 40,
                    condition: .rain,
                    isDaytime: true
                )
            },
            daily: []
        )
    }
}
