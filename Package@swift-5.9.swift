// swift-tools-version: 5.9
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
            targets: ["Botsi"]
        ),
        .library(
            name: "BotsiUI",
            targets: ["BotsiUI"]
        ),
        .library(
            name: "BotsiUITesting",
            targets: ["BotsiUITesting"]
        )
    ],
    targets: [
        .target(
            name: "Botsi",
            dependencies: [],
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "BotsiUI",
            dependencies: ["Botsi"],
            path: "BotsiUI",
            resources: [.copy("PrivacyInfo.xcprivacy")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),
        .target(
            name: "BotsiUITesting",
            dependencies: ["Botsi", "BotsiUI"],
            path: "BotsiUITesting"
        ),
        .testTarget(
            name: "BotsiTests",
            dependencies: ["Botsi"],
            path: "Tests"
        ),
    ]
)
