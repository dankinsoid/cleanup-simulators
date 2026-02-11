// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SimClean",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "SimulatorKit", targets: ["SimulatorKit"]),
        .executable(name: "simclean", targets: ["simclean"]),
        // SimCleanApp is now the Xcode project (CleanupSimulators)
        // TODO: MCP server
        // .executable(name: "SimCleanMCP", targets: ["SimCleanMCP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
        .package(url: "https://github.com/dankinsoid/swift-api-client.git", from: "1.73.0"),
        // TODO: MCP server
        // .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.10.0"),
    ],
    targets: [
        .target(
            name: "SimulatorKit"
        ),
        .executableTarget(
            name: "simclean",
            dependencies: [
                "SimulatorKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        // SimCleanApp is now the Xcode project (CleanupSimulators)
        // TODO: MCP server
        // .executableTarget(
        //     name: "SimCleanMCP",
        //     dependencies: [
        //         "SimulatorKit",
        //         .product(name: "ModelContextProtocol", package: "swift-sdk"),
        //     ]
        // ),
        .testTarget(
            name: "SimulatorKitTests",
            dependencies: ["SimulatorKit"]
        ),
    ]
)
