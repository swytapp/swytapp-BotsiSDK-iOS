// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Botsi",
    platforms: [
        .iOS(.v13),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Botsi",
            targets: ["Botsi"]),
    ],
    targets: [
        .target(
            name: "Botsi",
            path: "Sources"
        ),
        .testTarget(
            name: "BotsiSDK-iOSTests",
            dependencies: ["Botsi"],
            path: "Tests"
        ),
    ]
)
