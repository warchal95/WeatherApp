import WeatherDomain

struct StoredCity: Codable, Sendable {
    let id: Int
    let name: String
    let region: String?
    let country: String?
    let latitude: Double
    let longitude: Double
}

extension StoredCity {
    init(_ city: City) {
        self.init(
            id: city.id,
            name: city.name,
            region: city.region,
            country: city.country,
            latitude: city.coordinates.latitude,
            longitude: city.coordinates.longitude
        )
    }

    var city: City {
        City(id: id, name: name, region: region, country: country, coordinates: Coordinates(latitude: latitude, longitude: longitude))
    }
}
