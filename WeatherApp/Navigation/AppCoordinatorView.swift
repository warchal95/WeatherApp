import SharedUI
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
        .safeAreaInset(edge: .bottom) {
            ConnectivityBannerContainer(viewModel: coordinator.connectivityViewModel)
        }
    }
}

private struct ConnectivityBannerContainer: View {
    let viewModel: ConnectivityViewModel

    var body: some View {
        VStack {
            if viewModel.isOffline {
                OfflineBanner()
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.spring(duration: 0.4), value: viewModel.isOffline)
        .task { await viewModel.onLoad() }
    }
}
