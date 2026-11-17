import Observation
import WeatherDomain

@MainActor
@Observable
public final class ForecastViewModel {
    public static let hourlyForecastLength = 24

    public enum State: Equatable, Sendable {
        case loading
        case loaded(Forecast)
        case failed(DomainError)
    }

    public let city: City
    public private(set) var state: State = .loading
    public private(set) var refreshError: DomainError?

    private let getForecast: GetForecastUseCaseType

    public init(city: City, getForecast: GetForecastUseCaseType) {
        self.city = city
        self.getForecast = getForecast
    }

    public func onLoad() async {
        guard case .loading = state else { return }
        await load()
    }

    public func didTapRetry() async {
        state = .loading
        await load()
    }

    public func didPullToRefresh() async {
        guard case .loaded = state else {
            await didTapRetry()
            return
        }
        do {
            state = .loaded(try await fetchForecast())
            refreshError = nil
        } catch .cancelled {
            return
        } catch {
            refreshError = error
        }
    }

    private func load() async {
        do {
            state = .loaded(try await fetchForecast())
            refreshError = nil
        } catch .cancelled {
            return
        } catch {
            state = .failed(error)
        }
    }

    private func fetchForecast() async throws(DomainError) -> Forecast {
        let forecast = try await getForecast.execute(city)
        return Forecast(
            timeZone: forecast.timeZone,
            current: forecast.current,
            hourly: Array(forecast.hourly.prefix(Self.hourlyForecastLength)),
            daily: forecast.daily
        )
    }
}
