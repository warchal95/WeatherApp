import Foundation
import NetworkingTestSupport
import Networking
import Testing
import WeatherDomain
@testable import WeatherData

struct CityRepositoryTests {
    private let host = "\(UUID().uuidString).test"

    private func makeSUT(statusCode: Int = 200, body: Data, onRequest: @escaping @Sendable (URLRequest) -> Void = { _ in }) -> CityRepository {
        let session = URLProtocolStub.makeSession(host: host) { request in
            onRequest(request)
            return (.stub(url: request.url, statusCode: statusCode), body)
        }
        let configuration = OpenMeteoConfiguration(
            geocodingBaseURL: URL(string: "https://\(host)")!,
            languageCode: "pl",
            searchResultLimit: 5
        )
        return CityRepository(httpClient: HTTPClient(session: session), configuration: configuration)
    }

    @Test
    func requestsGeocodingSearchWithLanguageAndLimit() async throws {
        // Arrange
        let components = Locked<URLComponents>()
        let sut = makeSUT(body: Fixtures.geocoding) { request in
            components.value = request.url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
        }

        // Act
        _ = try await sut.searchCities(named: "Nowy Sącz")

        // Assert
        let captured = try #require(components.value)
        #expect(captured.path == "/v1/search")
        #expect(captured.queryItems?.contains(URLQueryItem(name: "name", value: "Nowy Sącz")) == true)
        #expect(captured.queryItems?.contains(URLQueryItem(name: "language", value: "pl")) == true)
        #expect(captured.queryItems?.contains(URLQueryItem(name: "count", value: "5")) == true)
    }

    @Test
    func returnsMappedCities() async throws {
        // Act
        let cities = try await makeSUT(body: Fixtures.geocoding).searchCities(named: "Bielsko-Biała")

        // Assert
        #expect(cities.map(\.name) == ["Bielsko-Biała", "Nowhere"])
    }

    @Test
    func returnsEmptyListWhenNothingMatches() async throws {
        // Act
        let cities = try await makeSUT(body: Fixtures.geocodingWithoutResults).searchCities(named: "Qwxzzy")

        // Assert
        #expect(cities.isEmpty)
    }

    @Test
    func throwsServerErrorWithAPIReason() async {
        // Arrange
        let sut = makeSUT(statusCode: 400, body: Fixtures.apiError)

        // Act & Assert
        await #expect(throws: DomainError.server(message: "Latitude must be in range of -90 to 90°. Given: 999.0.")) {
            try await sut.searchCities(named: "Kraków")
        }
    }
}
