import SwiftUI

public struct ForecastContainerView: View {
    @State private var viewModel: ForecastViewModel

    init(viewModel: ForecastViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ForecastView(
            city: viewModel.city,
            state: viewModel.state,
            refreshError: viewModel.refreshError,
            onRetry: { Task { await viewModel.didTapRetry() } }
        )
        .navigationTitle(viewModel.city.name)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await viewModel.didPullToRefresh() }
        .task { await viewModel.onLoad() }
    }
}
