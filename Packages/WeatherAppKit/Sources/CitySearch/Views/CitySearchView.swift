import SharedUI
import SwiftUI
import WeatherDomain

struct CitySearchView: View {
    let content: CitySearchViewModel.Content
    let validationIssue: CitySearchViewModel.ValidationIssue?
    let onSelect: (City) -> Void
    let onRemoveFromHistory: (City) -> Void
    let onRetry: () -> Void

    var body: some View {
        List {
            if let validationIssue {
                ValidationIssueRow(issue: validationIssue)
            }
            switch content {
            case .history(let cities) where !cities.isEmpty:
                Section {
                    ForEach(cities) { city in
                        CityRow(city: city, systemImage: "clock.arrow.circlepath", onSelect: onSelect)
                            .swipeActions {
                                Button(role: .destructive) {
                                    onRemoveFromHistory(city)
                                } label: {
                                    Label(String(localized: "Remove", bundle: .module), systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    Text("Recent searches", bundle: .module)
                }
            case .results(let cities):
                Section {
                    ForEach(cities) { city in
                        CityRow(city: city, systemImage: "mappin.and.ellipse", onSelect: onSelect)
                    }
                } header: {
                    Text("Results", bundle: .module)
                }
            case .history, .queryTooShort, .loading, .noResults, .failed:
                EmptyView()
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if validationIssue == nil {
                CitySearchStateOverlay(content: content, onRetry: onRetry)
            }
        }
        .animation(.default, value: content)
        .animation(.default, value: validationIssue)
    }
}

private struct CitySearchStateOverlay: View {
    let content: CitySearchViewModel.Content
    let onRetry: () -> Void

    var body: some View {
        switch content {
        case .history(let cities) where cities.isEmpty:
            ContentUnavailableView {
                Label(String(localized: "Search for a city", bundle: .module), systemImage: "magnifyingglass")
            } description: {
                Text("Type a city name to see its weather forecast. Cities you open are saved here.", bundle: .module)
            }
        case .queryTooShort(let minimumLength):
            ContentUnavailableView {
                Label(String(localized: "Keep typing", bundle: .module), systemImage: "character.cursor.ibeam")
            } description: {
                Text("Type at least \(minimumLength) letters to search.", bundle: .module)
            }
        case .loading:
            LoadingStateView(title: String(localized: "Searching…", bundle: .module))
        case .noResults(let query):
            ContentUnavailableView.search(text: query)
        case .failed(let error):
            ErrorStateView(error: error, onRetry: onRetry)
        case .history, .results:
            EmptyView()
        }
    }
}

private struct ValidationIssueRow: View {
    let issue: CitySearchViewModel.ValidationIssue

    var body: some View {
        Label {
            switch issue {
            case .containsDigits:
                Text("City names can't contain digits.", bundle: .module)
            case .containsDisallowedCharacters:
                Text("Use only letters, spaces and hyphens.", bundle: .module)
            }
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
        }
        .font(.footnote)
        .foregroundStyle(.red)
        .accessibilityAddTraits(.isStaticText)
    }
}

private struct CityRow: View {
    let city: City
    let systemImage: String
    let onSelect: (City) -> Void

    var body: some View {
        Button {
            onSelect(city)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(city.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                    if let subtitle = city.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(Text("Shows the weather forecast", bundle: .module))
    }
}

private extension City {
    var subtitle: String? {
        let parts = [region, country].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}

private let previewCities = [
    City(id: 1, name: "Bielsko-Biała", region: "Województwo śląskie", country: "Polska", coordinates: Coordinates(latitude: 49.82, longitude: 19.05)),
    City(id: 2, name: "Nowy Sącz", region: "Województwo małopolskie", country: "Polska", coordinates: Coordinates(latitude: 49.62, longitude: 20.69)),
    City(id: 3, name: "Łódź", region: "Województwo łódzkie", country: "Polska", coordinates: Coordinates(latitude: 51.77, longitude: 19.46))
]

private struct CitySearchPreview: View {
    let content: CitySearchViewModel.Content
    var validationIssue: CitySearchViewModel.ValidationIssue?

    var body: some View {
        NavigationStack {
            CitySearchView(content: content, validationIssue: validationIssue, onSelect: { _ in }, onRemoveFromHistory: { _ in }, onRetry: {})
                .navigationTitle("Weather")
        }
    }
}

#Preview("History") { CitySearchPreview(content: .history(previewCities)) }
#Preview("History – Dark") { CitySearchPreview(content: .history(previewCities)).preferredColorScheme(.dark) }
#Preview("Empty history") { CitySearchPreview(content: .history([])) }
#Preview("Results") { CitySearchPreview(content: .results(previewCities)) }
#Preview("Results – Dark") { CitySearchPreview(content: .results(previewCities)).preferredColorScheme(.dark) }
#Preview("Too short") { CitySearchPreview(content: .queryTooShort(minimumLength: 2)) }
#Preview("Loading") { CitySearchPreview(content: .loading) }
#Preview("No results") { CitySearchPreview(content: .noResults(query: "Qwerty")) }
#Preview("Offline – Dark") { CitySearchPreview(content: .failed(.noConnection)).preferredColorScheme(.dark) }
#Preview("Invalid input") { CitySearchPreview(content: .results(previewCities), validationIssue: .containsDigits) }
