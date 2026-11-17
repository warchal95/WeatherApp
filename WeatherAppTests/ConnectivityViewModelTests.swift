import Networking
import Testing
@testable import WeatherApp

@MainActor
struct ConnectivityViewModelTests {
    @Test
    func followsConnectivityUpdates() async {
        // Arrange
        let monitor = NetworkMonitorMock()
        let sut = ConnectivityViewModel(networkMonitor: monitor)
        let observation = Task { await sut.onLoad() }

        // Act & Assert
        monitor.send(false)
        await waitUntil { sut.isOffline }
        #expect(sut.isOffline)

        monitor.send(true)
        await waitUntil { !sut.isOffline }
        #expect(!sut.isOffline)

        monitor.finish()
        await observation.value
    }

    @Test
    func startsOnline() {
        #expect(!ConnectivityViewModel(networkMonitor: NetworkMonitorMock()).isOffline)
    }

    private func waitUntil(_ condition: () -> Bool) async {
        for _ in 0..<100 where !condition() {
            await Task.yield()
        }
    }
}

final class NetworkMonitorMock: NetworkMonitoring, @unchecked Sendable {
    private let stream: AsyncStream<Bool>
    private let continuation: AsyncStream<Bool>.Continuation

    init() {
        (stream, continuation) = AsyncStream.makeStream(of: Bool.self)
    }

    func connectivityUpdates() -> AsyncStream<Bool> { stream }

    func send(_ isConnected: Bool) { continuation.yield(isConnected) }

    func finish() { continuation.finish() }
}
