// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WeatherAppKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "WeatherDomain", targets: ["WeatherDomain"])
    ],
    targets: [
        .target(name: "Networking"),
        .target(name: "WeatherDomain"),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking"]),
        .testTarget(name: "WeatherDomainTests", dependencies: ["WeatherDomain"])
    ]
)
