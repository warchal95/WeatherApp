import SwiftUI

public struct OfflineBanner: View {
    public init() {}

    public var body: some View {
        Label {
            Text("No internet connection", bundle: .module)
        } icon: {
            Image(systemName: "wifi.slash")
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.red.gradient, in: Capsule())
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isStaticText)
    }
}

#Preview {
    VStack(spacing: 24) {
        OfflineBanner()
        OfflineBanner().environment(\.colorScheme, .dark)
    }
    .padding()
}
