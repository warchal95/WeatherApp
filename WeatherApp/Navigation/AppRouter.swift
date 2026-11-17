import Observation
import WeatherDomain

@MainActor
@Observable
final class AppRouter {
    enum Destination: Hashable {
        case forecast(City)
    }

    var path: [Destination] = []

    func push(_ destination: Destination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}
