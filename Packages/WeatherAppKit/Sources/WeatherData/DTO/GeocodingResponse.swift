struct GeocodingResponse: Decodable, Sendable {
    /// Open-Meteo omits the key entirely when nothing matches.
    let results: [GeocodingResult]?
}

struct GeocodingResult: Decodable, Sendable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?
}
