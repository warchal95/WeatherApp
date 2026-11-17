import Foundation
import NetworkingTestSupport
import Networking
import Testing
import WeatherDomain
@testable import WeatherData

struct ForecastRepositoryTests {
    private let host = "\(UUID().uuidString).test"

    private func makeSUT(
        body: Data,
        onRequest: @escaping @Sendable (URLRequest) -> Void = { _ in }
    ) -> ForecastRepository {
        let session = URLProtocolStub.makeSession(host: host) { request in
            onRequest(request)
            return (.stub(url: request.url), body)
        }
        let configuration = OpenMeteoConfiguration(forecastBaseURL: URL(string: "https://\(host)")!, languageCode: "pl")
        return ForecastRepository(httpClient: HTTPClient(session: session), configuration: configuration)
    }

    @Test
    func requestsForecastForCoordinatesInLocalTimeZone() async throws {
        // Arrange
        let components = Locked<URLComponents>()
        let sut = makeSUT(body: Fixtures.forecast) { request in
            components.value = request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        }

        // Act
        _ = try await sut.forecast(at: Coordinates(latitude: 49.82, longitude: 19.04))

        // Assert
        let captured = try #require(components.value)
        let items = try #require(captured.queryItems)
        #expect(captured.path == "/v1/forecast")
        #expect(items.contains(URLQueryItem(name: "latitude", value: "49.82")))
        #expect(items.contains(URLQueryItem(name: "longitude", value: "19.04")))
        #expect(items.contains(URLQueryItem(name: "timezone", value: "auto")))
    }

    @Test
    func returnsMappedForecast() async throws {
        // Act
        let forecast = try await makeSUT(body: Fixtures.forecast).forecast(at: Coordinates(latitude: 0, longitude: 0))

        // Assert
        #expect(forecast.current.cloudCoverPercent == 100)
        #expect(!forecast.hourly.isEmpty)
    }

    @Test
    func throwsInvalidResponseForMalformedPayload() async {
        // Arrange
        let sut = makeSUT(body: Data(#"{"current":{}}"#.utf8))

        // Act & Assert
        await #expect(throws: DomainError.invalidResponse) {
            try await sut.forecast(at: Coordinates(latitude: 0, longitude: 0))
        }
    }
}
