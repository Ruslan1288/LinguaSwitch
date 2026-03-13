// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LayoutSwitcher",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "LayoutSwitcher", targets: ["LayoutSwitcher"])
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0")
    ],
    targets: [
        .executableTarget(
            name: "LayoutSwitcher",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "Sources/LayoutSwitcher",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "LayoutSwitcherTests",
            dependencies: ["LayoutSwitcher"],
            path: "Tests/LayoutSwitcherTests"
        )
    ]
)
