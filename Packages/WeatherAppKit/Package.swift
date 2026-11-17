// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "WeatherAppKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "WeatherDomain", targets: ["WeatherDomain"]),
        .library(name: "WeatherData", targets: ["WeatherData"])
    ],
    targets: [
        .target(name: "Networking"),
        .target(name: "WeatherDomain"),
        .target(name: "WeatherData", dependencies: ["WeatherDomain", "Networking"]),
        .target(name: "NetworkingTestSupport"),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking", "NetworkingTestSupport"]),
        .testTarget(name: "WeatherDomainTests", dependencies: ["WeatherDomain"]),
        .testTarget(name: "WeatherDataTests", dependencies: ["WeatherData", "NetworkingTestSupport"])
    ]
)
