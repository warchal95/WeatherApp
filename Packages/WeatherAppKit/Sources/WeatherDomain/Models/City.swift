public struct City: Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let region: String?
    public let country: String?
    public let coordinates: Coordinates

    public init(id: Int, name: String, region: String?, country: String?, coordinates: Coordinates) {
        self.id = id
        self.name = name
        self.region = region
        self.country = country
        self.coordinates = coordinates
    }
}

public struct Coordinates: Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
