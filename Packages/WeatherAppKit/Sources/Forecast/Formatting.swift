import Foundation

extension Measurement where UnitType == UnitTemperature {
    var formattedTemperature: String {
        formatted(.measurement(width: .narrow, usage: .weather, numberFormatStyle: .number.precision(.fractionLength(0))))
    }
}

extension Int {
    var formattedPercent: String {
        (Double(self) / 100).formatted(.percent.precision(.fractionLength(0)))
    }
}

extension Optional where Wrapped == Int {
    var formattedPercent: String {
        map(\.formattedPercent) ?? "–"
    }
}

extension Date {
    func formattedHour(in timeZone: TimeZone) -> String {
        var style = Date.FormatStyle(date: .omitted, time: .shortened)
        style.timeZone = timeZone
        return formatted(style)
    }

    func formattedWeekday(in timeZone: TimeZone) -> String {
        var style = Date.FormatStyle.dateTime.weekday(.wide)
        style.timeZone = timeZone
        return formatted(style).localizedCapitalized
    }
}
