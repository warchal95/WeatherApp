import SwiftUI

public struct LoadingStateView: View {
    private let title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        ProgressView(title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingStateView(title: "Loading…")
}
