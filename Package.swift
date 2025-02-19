// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Botsi",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "Botsi",
            targets: ["Botsi"]),
    ],
    targets: [
        .target(
            name: "Botsi",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "BotsiSDK-iOSTests",
            dependencies: ["Botsi"],
            path: "Tests"
        ),
    ]
)
