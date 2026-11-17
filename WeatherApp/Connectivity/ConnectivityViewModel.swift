import Networking
import Observation

@MainActor
@Observable
final class ConnectivityViewModel {
    private(set) var isOffline = false

    private let networkMonitor: NetworkMonitoring

    init(networkMonitor: NetworkMonitoring) {
        self.networkMonitor = networkMonitor
    }

    func onLoad() async {
        for await isConnected in networkMonitor.connectivityUpdates() {
            isOffline = !isConnected
        }
    }
}
