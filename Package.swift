// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Botsi",
    platforms: [
        .iOS(.v13),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Botsi",
            targets: ["Botsi"]
        ),
        .library(
            name: "BotsiUI",
            targets: ["BotsiUI"]
        )
    ],
    targets: [
        .target(
            name: "Botsi",
            path: "Sources"
        ),
        .target(
            name: "BotsiUI",
            dependencies: ["Botsi"],
            path: "BotsiUI"
        ),
        .testTarget(
            name: "BotsiSDK-iOSTests",
            dependencies: ["Botsi"],
            path: "Tests"
        )
    ]
)
