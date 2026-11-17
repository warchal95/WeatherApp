import WeatherDomain

enum CityMapper {
    static func map(_ response: GeocodingResponse) -> [City] {
        (response.results ?? []).map(map)
    }

    static func map(_ result: GeocodingResult) -> City {
        City(
            id: result.id,
            name: result.name,
            region: result.admin1,
            country: result.country,
            coordinates: Coordinates(latitude: result.latitude, longitude: result.longitude)
        )
    }
}
