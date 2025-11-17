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
        .target(
            name: "SleepTimerCore",
            path: "Sources/SleepTimerCore"
        ),
        .executableTarget(
            name: "SleepTimer",
            dependencies: ["SleepTimerCore"],
            path: "Sources/SleepTimer"
        ),
        .testTarget(
            name: "SleepTimerTests",
            dependencies: ["SleepTimerCore"],
            path: "Tests"
        )
    ]
)

