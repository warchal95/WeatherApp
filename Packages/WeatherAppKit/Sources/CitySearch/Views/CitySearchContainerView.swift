import SwiftUI

public struct CitySearchContainerView: View {
    @State private var viewModel: CitySearchViewModel

    init(viewModel: CitySearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        CitySearchView(
            content: viewModel.content,
            validationIssue: viewModel.validationIssue,
            onSelect: { city in Task { await viewModel.didSelect(city) } },
            onRemoveFromHistory: { city in Task { await viewModel.didRemoveFromHistory(city) } },
            onRetry: { viewModel.didTapRetry() }
        )
        .navigationTitle(Text("Weather", bundle: .module))
        .searchable(
            text: $viewModel.query,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: Text("City name", bundle: .module)
        )
        .autocorrectionDisabled()
        .textInputAutocapitalization(.words)
        .task { await viewModel.onLoad() }
    }
}
