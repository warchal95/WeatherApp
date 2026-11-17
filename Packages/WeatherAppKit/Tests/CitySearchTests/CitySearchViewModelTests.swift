import Testing
import WeatherDomain
@testable import CitySearch

@MainActor
struct CitySearchViewModelTests {
    private let searchCities = SearchCitiesUseCaseMock()
    private let getSearchHistory = GetSearchHistoryUseCaseMock()
    private let addCityToSearchHistory = AddCityToSearchHistoryUseCaseMock()
    private let removeCityFromSearchHistory = RemoveCityFromSearchHistoryUseCaseMock()

    private func makeSUT() -> CitySearchViewModel {
        CitySearchViewModel(
            searchCities: searchCities,
            getSearchHistory: getSearchHistory,
            addCityToSearchHistory: addCityToSearchHistory,
            removeCityFromSearchHistory: removeCityFromSearchHistory,
            debounce: .zero
        )
    }

    private func search(_ query: String, in sut: CitySearchViewModel) async {
        sut.query = query
        await sut.searchTask?.value
    }

    @Test
    func onLoadShowsSavedHistory() async {
        // Arrange
        let history = [City.mock(id: 1), .mock(id: 2)]
        getSearchHistory.executeResult = .success(history)
        let sut = makeSUT()

        // Act
        await sut.onLoad()

        // Assert
        #expect(sut.content == .history(history))
    }

    @Test
    func onLoadFallsBackToEmptyHistoryWhenStorageFails() async {
        // Arrange
        getSearchHistory.executeResult = .failure(.storage)
        let sut = makeSUT()

        // Act
        await sut.onLoad()

        // Assert
        #expect(sut.content == .history([]))
    }

    @Test
    func validQueryShowsResults() async {
        // Arrange
        let cities = [City.mock(id: 7, name: "Bielsko-Biała")]
        searchCities.executeResult = .success(cities)
        let sut = makeSUT()

        // Act
        await search("Bielsko-Biała", in: sut)

        // Assert
        #expect(sut.content == .results(cities))
        #expect(searchCities.receivedQueries == ["Bielsko-Biała"])
        #expect(sut.validationIssue == nil)
    }

    @Test
    func emptyResultShowsNoResultsWithNormalizedQuery() async {
        // Arrange
        searchCities.executeResult = .success([])
        let sut = makeSUT()

        // Act
        await search("  Qwerty ", in: sut)

        // Assert
        #expect(sut.content == .noResults(query: "Qwerty"))
    }

    @Test
    func failedSearchShowsError() async {
        // Arrange
        searchCities.executeResult = .failure(.noConnection)
        let sut = makeSUT()

        // Act
        await search("Gdańsk", in: sut)

        // Assert
        #expect(sut.content == .failed(.noConnection))
    }

    @Test
    func retryRepeatsSearchForCurrentQuery() async {
        // Arrange
        searchCities.executeResult = .failure(.noConnection)
        let sut = makeSUT()
        await search("Gdańsk", in: sut)
        searchCities.executeResult = .success([.mock(name: "Gdańsk")])

        // Act
        sut.didTapRetry()
        await sut.searchTask?.value

        // Assert
        #expect(sut.content == .results([.mock(name: "Gdańsk")]))
        #expect(searchCities.receivedQueries == ["Gdańsk", "Gdańsk"])
    }

    @Test(arguments: [
        ("Kraków2", CitySearchViewModel.ValidationIssue.containsDigits),
        ("War$zawa", .containsDisallowedCharacters)
    ])
    func invalidQueryReportsIssueWithoutSearching(query: String, issue: CitySearchViewModel.ValidationIssue) async {
        // Arrange
        let sut = makeSUT()

        // Act
        await search(query, in: sut)

        // Assert
        #expect(sut.validationIssue == issue)
        #expect(sut.searchTask == nil)
        #expect(searchCities.receivedQueries.isEmpty)
    }

    @Test
    func singleLetterAsksForLongerQueryWithoutSearching() async {
        // Arrange
        let sut = makeSUT()

        // Act
        await search("W", in: sut)

        // Assert
        #expect(sut.content == .queryTooShort(minimumLength: SearchCitiesUseCase.minimumQueryLength))
        #expect(searchCities.receivedQueries.isEmpty)
    }

    @Test
    func clearingQueryReturnsToHistory() async {
        // Arrange
        let history = [City.mock(id: 3)]
        getSearchHistory.executeResult = .success(history)
        let sut = makeSUT()
        await sut.onLoad()
        await search("Opole", in: sut)

        // Act
        await search("", in: sut)

        // Assert
        #expect(sut.content == .history(history))
    }

    @Test
    func newQueryCancelsPendingSearch() async {
        // Arrange
        let sut = CitySearchViewModel(
            searchCities: searchCities,
            getSearchHistory: getSearchHistory,
            addCityToSearchHistory: addCityToSearchHistory,
            removeCityFromSearchHistory: removeCityFromSearchHistory,
            debounce: .seconds(10)
        )
        sut.query = "Kra"
        let pendingSearch = sut.searchTask

        // Act
        sut.query = ""
        await pendingSearch?.value

        // Assert
        #expect(pendingSearch?.isCancelled == true)
        #expect(searchCities.receivedQueries.isEmpty)
    }

    @Test
    func selectingCityShowsForecastAndSavesItToHistory() async {
        // Arrange
        let city = City.mock(id: 9, name: "Nowy Sącz")
        var capturedAction: CitySearchViewModel.Action?
        let sut = makeSUT()
        sut.onAction = { capturedAction = $0 }

        // Act
        await sut.didSelect(city)

        // Assert
        #expect(capturedAction == .showForecast(city))
        #expect(addCityToSearchHistory.receivedCities == [city])
    }

    @Test
    func removingCityFromHistoryUpdatesHistory() async {
        // Arrange
        let remaining = [City.mock(id: 2)]
        getSearchHistory.executeResult = .success([.mock(id: 1), .mock(id: 2)])
        removeCityFromSearchHistory.executeResult = .success(remaining)
        let sut = makeSUT()
        await sut.onLoad()

        // Act
        await sut.didRemoveFromHistory(.mock(id: 1))

        // Assert
        #expect(sut.content == .history(remaining))
        #expect(removeCityFromSearchHistory.receivedCities == [.mock(id: 1)])
    }
}
