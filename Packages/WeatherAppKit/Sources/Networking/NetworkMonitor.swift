import Foundation
import Network

public protocol NetworkMonitoring: Sendable {
    func connectivityUpdates() -> AsyncStream<Bool>
}

public protocol HasNetworkMonitor: Sendable {
    var networkMonitor: NetworkMonitoring { get }
}

public struct NetworkMonitor: NetworkMonitoring {
    public init() {}

    public func connectivityUpdates() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                continuation.yield(path.status == .satisfied)
            }
            continuation.onTermination = { _ in
                monitor.cancel()
            }
            monitor.start(queue: DispatchQueue(label: "com.warchal.WeatherApp.NetworkMonitor"))
        }
    }
}
