import Testing
import WeatherDomain

struct CityNameValidatorTests {
    private let sut = CityNameValidator()

    @Test(arguments: ["Warszawa", "Bielsko-Biała", "Nowy Sącz", "Łódź", "Źródła", "ŻÓŁĆ", "Kędzierzyn-Koźle", "München", "São Paulo"])
    func acceptsValidCityNames(name: String) {
        #expect(sut.validate(name) == .valid)
    }

    @Test(arguments: ["Kraków2", "1", "Gdańsk 3", "Opole٣"])
    func rejectsDigits(name: String) {
        #expect(sut.validate(name) == .containsDigits)
    }

    @Test(arguments: ["War$zawa", "Poznań!", "Lublin_", "Toruń.", "St. Petersburg", "O'Hare", "Łódź🙂"])
    func rejectsSpecialCharacters(name: String) {
        #expect(sut.validate(name) == .containsDisallowedCharacters)
    }

    @Test(arguments: ["", "   ", "-", " - "])
    func treatsBlankInputAsEmpty(name: String) {
        #expect(sut.validate(name) == .empty)
    }

    @Test
    func acceptsDecomposedPolishCharacters() {
        // Arrange
        let decomposed = "Sa\u{0328}cz"

        // Act
        let result = sut.validate(decomposed)

        // Assert
        #expect(result == .valid)
        #expect(sut.normalize(decomposed) == "Sącz")
    }

    @Test(arguments: [
        ("  Nowy   Sącz  ", "Nowy Sącz"),
        ("Bielsko-", "Bielsko"),
        ("-Biała", "Biała"),
        ("Bielsko-Biała", "Bielsko-Biała")
    ])
    func normalizesWhitespaceAndEdgeHyphens(input: String, expected: String) {
        #expect(sut.normalize(input) == expected)
    }
}
