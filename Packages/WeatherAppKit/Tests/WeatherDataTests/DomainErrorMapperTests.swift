import Foundation
import Networking
import Testing
import WeatherDomain
@testable import WeatherData

struct DomainErrorMapperTests {
    @Test(arguments: [
        (NetworkError.noConnection, DomainError.noConnection),
        (.timedOut, .noConnection),
        (.transport(.cannotFindHost), .noConnection),
        (.transport(.badServerResponse), .server(message: nil)),
        (.cancelled, .cancelled),
        (.invalidResponse, .invalidResponse),
        (.decoding(description: "missing key"), .invalidResponse),
        (.httpStatus(code: 500, body: Data("<html>".utf8)), .server(message: nil))
    ])
    func mapsNetworkErrors(error: NetworkError, expected: DomainError) {
        #expect(DomainErrorMapper.map(error) == expected)
    }

    @Test
    func extractsReasonFromOpenMeteoErrorBody() {
        // Act
        let result = DomainErrorMapper.map(.httpStatus(code: 400, body: Fixtures.apiError))

        // Assert
        #expect(result == .server(message: "Latitude must be in range of -90 to 90°. Given: 999.0."))
    }
}
