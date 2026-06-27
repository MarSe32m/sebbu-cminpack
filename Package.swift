// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sebbu-cminpack",
    products: [
        .library(
            name: "CMinpack",
            targets: ["CMinpack"]
        ),
    ],
    targets: [
        .target(
            name: "CMinpack",
            path: "Sources/CMinpack",
            cSettings: [
                .define("CMINPACK_NO_DLL")
            ],
            linkerSettings: [
                .linkedLibrary("m", .when(platforms: [.linux]))
            ]
        ),
        .executableTarget(
            name: "Development",
            dependencies: ["CMinpack"]
        )
    ],
    swiftLanguageModes: [.v6]
)
