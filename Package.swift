// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SleepTimer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "SleepTimer",
            targets: ["SleepTimer"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SleepTimer",
            path: "Sources"
        )
    ]
)

