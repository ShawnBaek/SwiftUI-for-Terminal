// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftUI-for-Terminal",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(name: "NotcursesSwift", targets: ["NotcursesSwift"]),
        .library(name: "TerminalUI", targets: ["TerminalUI"]),
        .executable(name: "Example", targets: ["Example"]),
    ],
    targets: [
        // Layer 1: Vendored C implementation (no external dependencies)
        .target(
            name: "Cnotcurses",
            publicHeadersPath: "include",
            cSettings: [.headerSearchPath("src")]
        ),

        // Layer 2: Safe Swift wrapper
        .target(
            name: "NotcursesSwift",
            dependencies: ["Cnotcurses"]
        ),

        // Layer 3: SwiftUI-compatible declarative API
        .target(
            name: "TerminalUI",
            dependencies: ["NotcursesSwift"]
        ),

        // Example app
        .executableTarget(
            name: "Example",
            dependencies: ["TerminalUI"]
        ),

        // Tests
        .testTarget(
            name: "NotcursesSwiftTests",
            dependencies: ["NotcursesSwift"]
        ),
        .testTarget(
            name: "TerminalUITests",
            dependencies: ["TerminalUI"]
        ),
    ]
)
