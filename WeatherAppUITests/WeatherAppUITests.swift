import XCTest

final class WeatherAppUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsSearchField() {
        // Arrange
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]

        // Act
        app.launch()

        // Assert
        XCTAssertTrue(app.searchFields["City name"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testTypingDigitsShowsValidationMessage() {
        // Arrange
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        let searchField = app.searchFields["City name"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))

        // Act
        searchField.tap()
        searchField.typeText("Krakow2")

        // Assert
        XCTAssertTrue(app.staticTexts["City names can't contain digits."].waitForExistence(timeout: 2))
    }
}
