// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "StoperAppCore",
    products: [
        .library(
            name: "StoperAppCore",
            targets: ["StoperAppCore"]
        )
    ],
    targets: [
        .target(
            name: "StoperAppCore",
            path: ".",
            exclude: [
                "App",
                "Tests",
                "UI"
            ],
            sources: [
                "Domain",
                "Engine",
                "Features",
                "Logging",
                "Persistence"
            ]
        ),
        .testTarget(
            name: "StoperAppCoreTests",
            dependencies: ["StoperAppCore"],
            path: "Tests"
        )
    ]
)
