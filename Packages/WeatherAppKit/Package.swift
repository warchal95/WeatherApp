// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WeatherAppKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Networking", targets: ["Networking"])
    ],
    targets: [
        .target(name: "Networking"),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking"])
    ]
)
