// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SbxMonitor",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftTerm", .upToNextMinor(from: "1.10.0"))
    ],
    targets: [
        .executableTarget(
            name: "SbxMonitor",
            dependencies: [
                .product(name: "SwiftTerm", package: "SwiftTerm")
            ],
            path: "Sources/SbxMonitor"
        )
    ]
)
