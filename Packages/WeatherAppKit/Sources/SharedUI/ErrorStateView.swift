import SwiftUI
import WeatherDomain

public struct ErrorStateView: View {
    private let error: DomainError
    private let onRetry: () -> Void

    public init(error: DomainError, onRetry: @escaping () -> Void) {
        self.error = error
        self.onRetry = onRetry
    }

    public var body: some View {
        ContentUnavailableView {
            Label(error.title, systemImage: error.systemImage)
        } description: {
            Text(error.message)
        } actions: {
            Button(String(localized: "Try again", bundle: .module), action: onRetry)
                .buttonStyle(.borderedProminent)
        }
    }
}

private extension DomainError {
    var title: String {
        switch self {
        case .noConnection: String(localized: "No internet connection", bundle: .module)
        case .storage: String(localized: "Couldn't access saved data", bundle: .module)
        case .invalidQuery, .cancelled, .server, .invalidResponse: String(localized: "Something went wrong", bundle: .module)
        }
    }

    var message: String {
        switch self {
        case .noConnection:
            String(localized: "Check your connection and try again.", bundle: .module)
        case .server(let message?):
            message
        case .invalidQuery, .cancelled, .server(nil), .invalidResponse, .storage:
            String(localized: "The weather service didn't respond as expected. Please try again in a moment.", bundle: .module)
        }
    }

    var systemImage: String {
        switch self {
        case .noConnection: "wifi.slash"
        case .storage: "externaldrive.badge.exclamationmark"
        case .invalidQuery, .cancelled, .server, .invalidResponse: "exclamationmark.icloud"
        }
    }
}

#Preview("No connection") {
    ErrorStateView(error: .noConnection, onRetry: {})
}

#Preview("Server message – Dark") {
    ErrorStateView(error: .server(message: "Latitude must be in range of -90 to 90°."), onRetry: {})
        .preferredColorScheme(.dark)
}
