import Testing
import WeatherDomain
@testable import WeatherData

struct CityMapperTests {
    @Test
    func mapsGeocodingResultsToCities() throws {
        // Arrange
        let response: GeocodingResponse = try Fixtures.decode(Fixtures.geocoding)

        // Act
        let cities = CityMapper.map(response)

        // Assert
        #expect(cities == [
            City(
                id: 3103402,
                name: "Bielsko-Biała",
                region: "Województwo śląskie",
                country: "Polska",
                coordinates: Coordinates(latitude: 49.82245, longitude: 19.04686)
            ),
            City(id: 1, name: "Nowhere", region: nil, country: nil, coordinates: Coordinates(latitude: 1.5, longitude: 2.5))
        ])
    }

    @Test
    func mapsMissingResultsToEmptyList() throws {
        // Arrange
        let response: GeocodingResponse = try Fixtures.decode(Fixtures.geocodingWithoutResults)

        // Act & Assert
        #expect(CityMapper.map(response).isEmpty)
    }
}
