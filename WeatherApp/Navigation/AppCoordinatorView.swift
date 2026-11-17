import SwiftUI

struct AppCoordinatorView: View {
    let coordinator: AppCoordinator
    @Bindable var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            coordinator.rootView
                .navigationDestination(for: AppRouter.Destination.self) { destination in
                    coordinator.view(for: destination)
                }
        }
    }
}
