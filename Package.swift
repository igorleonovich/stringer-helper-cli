// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "StringerHelperCLI",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.2.0")),
    ],
    targets: [
        .target(
            name: "StringerHelperCLI",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser"),]),
        .testTarget(
            name: "StringerHelperCLITests",
            dependencies: ["StringerHelperCLI"]),
    ]
)
