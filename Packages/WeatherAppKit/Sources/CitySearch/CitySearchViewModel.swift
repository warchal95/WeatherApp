import Foundation
import Observation
import os
import WeatherDomain

@MainActor
@Observable
public final class CitySearchViewModel {
    public enum Action: Equatable, Sendable {
        case showForecast(City)
    }

    public enum Content: Equatable, Sendable {
        case history([City])
        case queryTooShort(minimumLength: Int)
        case loading
        case results([City])
        case noResults(query: String)
        case failed(DomainError)
    }

    public enum ValidationIssue: Equatable, Sendable {
        case containsDigits
        case containsDisallowedCharacters
    }

    public var query = "" {
        didSet {
            guard query != oldValue else { return }
            queryDidChange()
        }
    }

    public private(set) var content: Content = .history([])
    public private(set) var validationIssue: ValidationIssue?

    @ObservationIgnored
    public var onAction: @MainActor (Action) -> Void = { _ in
        assertionFailure("onAction needs to be set")
    }

    @ObservationIgnored
    private(set) var searchTask: Task<Void, Never>?
    @ObservationIgnored
    private var history: [City] = []

    private let searchCities: SearchCitiesUseCaseType
    private let getSearchHistory: GetSearchHistoryUseCaseType
    private let addCityToSearchHistory: AddCityToSearchHistoryUseCaseType
    private let removeCityFromSearchHistory: RemoveCityFromSearchHistoryUseCaseType
    private let validator: CityNameValidator
    private let debounce: Duration

    private static let logger = Logger(subsystem: "com.warchal.WeatherApp", category: "CitySearch")

    public init(
        searchCities: SearchCitiesUseCaseType,
        getSearchHistory: GetSearchHistoryUseCaseType,
        addCityToSearchHistory: AddCityToSearchHistoryUseCaseType,
        removeCityFromSearchHistory: RemoveCityFromSearchHistoryUseCaseType,
        validator: CityNameValidator = CityNameValidator(),
        debounce: Duration = .milliseconds(400)
    ) {
        self.searchCities = searchCities
        self.getSearchHistory = getSearchHistory
        self.addCityToSearchHistory = addCityToSearchHistory
        self.removeCityFromSearchHistory = removeCityFromSearchHistory
        self.validator = validator
        self.debounce = debounce
    }

    public func onLoad() async {
        do {
            history = try await getSearchHistory.execute()
        } catch {
            Self.logger.error("Loading search history failed: \(String(describing: error))")
        }
        if validator.normalize(query).isEmpty {
            content = .history(history)
        }
    }

    public func didSelect(_ city: City) async {
        onAction(.showForecast(city))
        await updateHistory { [addCityToSearchHistory] () async throws(DomainError) in
            try await addCityToSearchHistory.execute(city)
        }
    }

    public func didRemoveFromHistory(_ city: City) async {
        await updateHistory { [removeCityFromSearchHistory] () async throws(DomainError) in
            try await removeCityFromSearchHistory.execute(city)
        }
    }

    public func didTapRetry() {
        startSearch(after: .zero)
    }

    private func queryDidChange() {
        searchTask?.cancel()
        searchTask = nil

        switch validator.validate(query) {
        case .empty:
            validationIssue = nil
            content = .history(history)
        case .containsDigits:
            validationIssue = .containsDigits
        case .containsDisallowedCharacters:
            validationIssue = .containsDisallowedCharacters
        case .valid:
            validationIssue = nil
            if validator.normalize(query).count < SearchCitiesUseCase.minimumQueryLength {
                content = .queryTooShort(minimumLength: SearchCitiesUseCase.minimumQueryLength)
            } else {
                startSearch(after: debounce)
            }
        }
    }

    private func startSearch(after delay: Duration) {
        searchTask?.cancel()
        let query = query
        searchTask = Task { [weak self] in
            if delay > .zero {
                try? await Task.sleep(for: delay)
                guard !Task.isCancelled else { return }
            }
            await self?.search(query)
        }
    }

    private func search(_ query: String) async {
        content = .loading
        do {
            let cities = try await searchCities.execute(query)
            guard !Task.isCancelled else { return }
            content = cities.isEmpty ? .noResults(query: validator.normalize(query)) : .results(cities)
        } catch .cancelled {
            return
        } catch {
            guard !Task.isCancelled else { return }
            content = .failed(error)
        }
    }

    private func updateHistory(_ operation: () async throws(DomainError) -> [City]) async {
        do {
            history = try await operation()
        } catch {
            Self.logger.error("Updating search history failed: \(String(describing: error))")
            return
        }
        if case .history = content {
            content = .history(history)
        }
    }
}
