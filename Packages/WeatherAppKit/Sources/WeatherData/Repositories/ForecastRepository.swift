import Networking
import WeatherDomain

public struct ForecastRepository: ForecastRepositoryType {
    private let httpClient: HTTPClientType
    private let configuration: OpenMeteoConfiguration

    public init(httpClient: HTTPClientType, configuration: OpenMeteoConfiguration) {
        self.httpClient = httpClient
        self.configuration = configuration
    }

    public func forecast(at coordinates: Coordinates) async throws(DomainError) -> Forecast {
        let endpoint = OpenMeteoEndpoint.forecast(at: coordinates, configuration: configuration)
        let response: ForecastResponse
        do {
            response = try await httpClient.get(endpoint, as: ForecastResponse.self)
        } catch {
            throw DomainErrorMapper.map(error)
        }
        return try ForecastMapper.map(response)
    }
}
