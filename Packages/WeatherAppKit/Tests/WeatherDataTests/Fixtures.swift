import Foundation

enum Fixtures {
    static let geocoding = Data("""
    {"results":[{"id":3103402,"name":"Bielsko-Biała","latitude":49.82245,"longitude":19.04686,"country_code":"PL","country":"Polska","admin1":"Województwo śląskie"},
    {"id":1,"name":"Nowhere","latitude":1.5,"longitude":2.5}],"generationtime_ms":0.26}
    """.utf8)

    static let geocodingWithoutResults = Data(#"{"generationtime_ms":0.1}"#.utf8)

    static let apiError = Data(#"{"reason":"Latitude must be in range of -90 to 90°. Given: 999.0.","error":true}"#.utf8)

    /// Current time 10:15 UTC, hourly from 09:00 to 12:00 UTC.
    static let forecast = Data("""
    {"utc_offset_seconds":3600,"timezone":"Europe/Warsaw",
    "current":{"time":1794910500,"interval":900,"temperature_2m":7.9,"apparent_temperature":4.4,"cloud_cover":100,"weather_code":51,"is_day":1},
    "hourly":{"time":[1794906000,1794909600,1794913200,1794916800],
    "temperature_2m":[6.0,7.5,null,8.3],
    "precipitation_probability":[10,63,70,null],
    "weather_code":[3,61,61,2],
    "is_day":[1,1,1,0]},
    "daily":{"time":[1794870000,1794956400],
    "weather_code":[61,0],
    "temperature_2m_max":[10.1,null],
    "temperature_2m_min":[5.8,4.0],
    "precipitation_probability_max":[100,null]}}
    """.utf8)

    static func decode<T: Decodable>(_ data: Data, as type: T.Type = T.self) throws -> T {
        try JSONDecoder().decode(T.self, from: data)
    }
}
