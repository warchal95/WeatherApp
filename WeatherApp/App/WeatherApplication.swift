import SwiftUI

@main
struct WeatherApplication: App {
    @State private var coordinator = AppCoordinator(dependencies: AppDependencies())

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView(coordinator: coordinator, router: coordinator.router)
        }
    }
}
