import Foundation
import Testing
@testable import Forecast

struct TemperatureFormattingTests {
    @Test(arguments: [(-0.4, "0°"), (0.4, "0°"), (-1.6, "-2°"), (7.9, "8°")])
    func roundsToWholeDegreesWithoutNegativeZero(celsius: Double, expected: String) {
        // Arrange
        let temperature = Measurement(value: celsius, unit: UnitTemperature.celsius)

        // Act
        let formatted = temperature.formattedTemperature(locale: Locale(identifier: "en_GB"))

        // Assert
        #expect(formatted == expected)
    }

    @Test
    func convertsToFahrenheitForLocalesThatUseIt() {
        // Arrange
        let temperature = Measurement(value: 20, unit: UnitTemperature.celsius)

        // Act
        let formatted = temperature.formattedTemperature(locale: Locale(identifier: "en_US"))

        // Assert
        #expect(formatted == "68°")
    }
}
