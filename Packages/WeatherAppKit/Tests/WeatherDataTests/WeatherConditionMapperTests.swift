import Testing
import WeatherDomain
@testable import WeatherData

struct WeatherConditionMapperTests {
    @Test(arguments: [
        (0, WeatherCondition.clear),
        (1, .mainlyClear),
        (2, .partlyCloudy),
        (3, .overcast),
        (48, .fog),
        (53, .drizzle),
        (57, .freezingDrizzle),
        (65, .rain),
        (66, .freezingRain),
        (77, .snow),
        (81, .rainShowers),
        (86, .snowShowers),
        (99, .thunderstorm)
    ])
    func mapsWMOCodes(code: Int, expected: WeatherCondition) {
        #expect(WeatherConditionMapper.map(code) == expected)
    }

    @Test(arguments: [nil, 4, 100, -1])
    func mapsUnknownCodesToUnknown(code: Int?) {
        #expect(WeatherConditionMapper.map(code) == .unknown)
    }
}
