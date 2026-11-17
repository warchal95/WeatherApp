import Networking
import WeatherDomain

public struct CityRepository: CityRepositoryType {
    private let httpClient: HTTPClientType
    private let configuration: OpenMeteoConfiguration

    public init(httpClient: HTTPClientType, configuration: OpenMeteoConfiguration) {
        self.httpClient = httpClient
        self.configuration = configuration
    }

    public func searchCities(named name: String) async throws(DomainError) -> [City] {
        let endpoint = OpenMeteoEndpoint.search(name: name, configuration: configuration)
        do {
            return CityMapper.map(try await httpClient.get(endpoint, as: GeocodingResponse.self))
        } catch {
            throw DomainErrorMapper.map(error)
        }
    }
}
