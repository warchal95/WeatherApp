import SharedUI
import SwiftUI
import WeatherDomain

struct ForecastView: View {
    let city: City
    let state: ForecastViewModel.State
    let refreshError: DomainError?
    let onRetry: () -> Void

    var body: some View {
        switch state {
        case .loading:
            LoadingStateView(title: String(localized: "Loading forecast…", bundle: .module))
        case .failed(let error):
            ErrorStateView(error: error, onRetry: onRetry)
        case .loaded(let forecast):
            ForecastContentView(city: city, forecast: forecast, showsRefreshError: refreshError != nil)
        }
    }
}

private struct ForecastContentView: View {
    let city: City
    let forecast: Forecast
    let showsRefreshError: Bool

    var body: some View {
        List {
            if showsRefreshError {
                Label {
                    Text("Couldn't update the forecast. Pull down to try again.", bundle: .module)
                } icon: {
                    Image(systemName: "exclamationmark.arrow.triangle.2.circlepath")
                }
                .font(.footnote)
                .foregroundStyle(.orange)
            }
            Section {
                CurrentConditionsHeader(city: city, current: forecast.current)
                    .listRowBackground(Color.clear)
            }
            Section {
                CurrentConditionsDetails(current: forecast.current)
            }
            if !forecast.hourly.isEmpty {
                Section {
                    HourlyForecastStrip(hourly: forecast.hourly, timeZone: forecast.timeZone)
                        .listRowInsets(EdgeInsets())
                } header: {
                    Text("Next 24 hours", bundle: .module)
                }
            }
            if !forecast.daily.isEmpty {
                Section {
                    ForEach(Array(forecast.daily.enumerated()), id: \.element.id) { index, day in
                        DailyForecastRow(day: day, isToday: index == 0, timeZone: forecast.timeZone)
                    }
                } header: {
                    Text("Daily forecast", bundle: .module)
                }
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: showsRefreshError)
    }
}

private struct CurrentConditionsHeader: View {
    let city: City
    let current: CurrentConditions

    var body: some View {
        VStack(spacing: 8) {
            if let location = city.location {
                Text(location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Image(systemName: current.condition.symbolName(isDaytime: current.isDaytime))
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 64))
                .accessibilityHidden(true)
            Text(current.temperature.formattedTemperature)
                .font(.system(size: 76, weight: .thin, design: .rounded))
                .contentTransition(.numericText())
            Text(current.condition.localizedDescription)
                .font(.title3.weight(.medium))
            if let apparentTemperature = current.apparentTemperature {
                Text("Feels like \(apparentTemperature.formattedTemperature)", bundle: .module)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .animation(.default, value: current)
    }
}

private struct CurrentConditionsDetails: View {
    let current: CurrentConditions

    var body: some View {
        LabeledContent {
            Text(current.cloudCoverPercent.formattedPercent)
        } label: {
            Label(String(localized: "Cloud cover", bundle: .module), systemImage: "cloud")
        }
        LabeledContent {
            Text(current.precipitationProbabilityPercent.formattedPercent)
        } label: {
            Label(String(localized: "Chance of precipitation", bundle: .module), systemImage: "umbrella")
        }
    }
}

private struct HourlyForecastStrip: View {
    let hourly: [HourlyForecast]
    let timeZone: TimeZone

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 4) {
                ForEach(Array(hourly.enumerated()), id: \.element.id) { index, hour in
                    HourlyForecastCell(hour: hour, isNow: index == 0, timeZone: timeZone)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }
}

private struct HourlyForecastCell: View {
    let hour: HourlyForecast
    let isNow: Bool
    let timeZone: TimeZone

    var body: some View {
        VStack(spacing: 8) {
            Text(isNow ? String(localized: "Now", bundle: .module) : hour.date.formattedHour(in: timeZone))
                .font(.footnote.weight(isNow ? .semibold : .regular))
                .foregroundStyle(isNow ? .primary : .secondary)
            Image(systemName: hour.condition.symbolName(isDaytime: hour.isDaytime))
                .symbolRenderingMode(.multicolor)
                .font(.title2)
                .frame(height: 32)
                .accessibilityLabel(hour.condition.localizedDescription)
            Text(hour.temperature.formattedTemperature)
                .font(.body.weight(.medium))
            Label(hour.precipitationProbabilityPercent.formattedPercent, systemImage: "drop.fill")
                .labelStyle(CompactLabelStyle())
                .font(.caption2)
                .foregroundStyle(.blue)
        }
        .frame(minWidth: 56)
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

private struct DailyForecastRow: View {
    let day: DailyForecast
    let isToday: Bool
    let timeZone: TimeZone

    var body: some View {
        HStack(spacing: 12) {
            Text(isToday ? String(localized: "Today", bundle: .module) : day.date.formattedWeekday(in: timeZone))
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: day.condition.symbolName(isDaytime: true))
                .symbolRenderingMode(.multicolor)
                .frame(width: 32)
                .accessibilityLabel(day.condition.localizedDescription)
            Label(day.precipitationProbabilityPercent.formattedPercent, systemImage: "drop.fill")
                .labelStyle(CompactLabelStyle())
                .font(.caption)
                .foregroundStyle(.blue)
                .frame(width: 52, alignment: .leading)
            Text(day.minTemperature.formattedTemperature)
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
            Text(day.maxTemperature.formattedTemperature)
                .fontWeight(.medium)
                .frame(width: 40, alignment: .trailing)
        }
        .monospacedDigit()
        .accessibilityElement(children: .combine)
    }
}

private extension City {
    var location: String? {
        let parts = [region, country].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }
}

private struct CompactLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 2) {
            configuration.icon
            configuration.title
        }
    }
}

private let previewCity = City(
    id: 1,
    name: "Bielsko-Biała",
    region: "Województwo śląskie",
    country: "Polska",
    coordinates: Coordinates(latitude: 49.82, longitude: 19.05)
)

private let previewForecast: Forecast = {
    let start = Date(timeIntervalSince1970: 1_794_909_600)
    let conditions: [WeatherCondition] = [.clear, .partlyCloudy, .overcast, .rain, .rainShowers, .thunderstorm, .snow]
    return Forecast(
        timeZone: TimeZone(identifier: "Europe/Warsaw") ?? .current,
        current: CurrentConditions(
            date: start,
            temperature: Measurement(value: 7.9, unit: .celsius),
            apparentTemperature: Measurement(value: 4.4, unit: .celsius),
            cloudCoverPercent: 75,
            precipitationProbabilityPercent: 63,
            condition: .partlyCloudy,
            isDaytime: true
        ),
        hourly: (0..<24).map { hour in
            HourlyForecast(
                date: start.addingTimeInterval(TimeInterval(hour) * 3600),
                temperature: Measurement(value: 8 + Double(hour % 6), unit: .celsius),
                precipitationProbabilityPercent: (hour * 7) % 100,
                condition: conditions[hour % conditions.count],
                isDaytime: hour < 8
            )
        },
        daily: (0..<7).map { day in
            DailyForecast(
                date: start.addingTimeInterval(TimeInterval(day) * 86_400),
                minTemperature: Measurement(value: 2 + Double(day), unit: .celsius),
                maxTemperature: Measurement(value: 9 + Double(day), unit: .celsius),
                precipitationProbabilityPercent: day * 12,
                condition: conditions[day % conditions.count]
            )
        }
    )
}()

private struct ForecastPreview: View {
    let state: ForecastViewModel.State
    var refreshError: DomainError?

    var body: some View {
        NavigationStack {
            ForecastView(city: previewCity, state: state, refreshError: refreshError, onRetry: {})
                .navigationTitle(previewCity.name)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("Loaded") { ForecastPreview(state: .loaded(previewForecast)) }
#Preview("Loaded – Dark") { ForecastPreview(state: .loaded(previewForecast)).preferredColorScheme(.dark) }
#Preview("Refresh failed") { ForecastPreview(state: .loaded(previewForecast), refreshError: .noConnection) }
#Preview("Loading") { ForecastPreview(state: .loading) }
#Preview("Offline – Dark") { ForecastPreview(state: .failed(.noConnection)).preferredColorScheme(.dark) }
#Preview("API error") { ForecastPreview(state: .failed(.server(message: "Latitude must be in range of -90 to 90°."))) }
