// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ConcurrentCollections",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "ConcurrentCollections",
            targets: ["ConcurrentCollections"]
        )
    ],
    targets: [
        .target(
            name: "ConcurrentCollections",
            dependencies: []
        ),
        .testTarget(
            name: "ConcurrentCollectionsTests",
            dependencies: ["ConcurrentCollections"]
        )
    ]
)
