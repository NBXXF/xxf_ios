// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xxf_ios",
    platforms: [
        .iOS(.v13),
        .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "XXFExtensions",
            targets: ["XXFExtensions"]
        ),
        .library(
            name: "XXFAppkit",
            targets: ["XXFAppkit"]
        ),
        .library(
            name: "XXFLog",
            targets: ["XXFLog"]
        ),
        .library(
            name: "XXFSpeed",
            targets: ["XXFSpeed"]
        ),
        .library(
            name: "XXFFlow",
            targets: ["XXFFlow"]
        ),
        .library(
            name: "XXFHttp",
            targets: ["XXFHttp"]
        ),
        .library(
            name: "XXFDatabase",
            targets: ["XXFDatabase"]
        ),
        .library(
            name: "XXFDatabaseGrdb",
            targets: ["XXFDatabaseGrdb"]
        ),
        .library(
            name: "XXFDi",
            targets: ["XXFDi"]
        ),
        .library(
            name: "XXFHud",
            targets: ["XXFHud"]
        ),
        .library(
            name: "XXFHudMac",
            targets: ["XXFHudMac"]
        ),
        .library(
            name: "XXFArch",
            targets: ["XXFArch"]
        ),
        .library(
            name: "XXFPerformance",
            targets: ["XXFPerformance"]
        ),
    ],
    dependencies: [
        // 第三方依赖写这里
        /// 新的跨平台日志库 比os.Logger更好用,能更好扩展
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.3"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", from: "7.0.0"),
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3"),
        .package(url: "https://github.com/NBXXF/PulseCompat", .upToNextMajor(from: "4.2.7")),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.5.3"),
        .package(url: "https://github.com/groue/GRDB.swift", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/NBXXF/XXFHighwayHash.git", from: "0.0.2"),
        // .package(url: "https://github.com/relatedcode/ProgressHUD", from: "14.1.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "XXFExtensions",
            dependencies: [
                .product(name: "SwifterSwift", package: "SwifterSwift"),
                "XXFSpeed",
            ]
        ),
        .target(
            name: "XXFAppkit"
        ),
        .target(
            name: "XXFXXHash",
            path: "Sources/XXFXXHash",
            publicHeadersPath: "include" // 👈 必须显式指向这个目录
        ),
        .target(
            name: "XXFSpeed",
            dependencies: [
                .product(name: "HighwayHash", package: "XXFHighwayHash"),
                "XXFXXHash",
            ]
        ),
        .target(
            name: "XXFLog",
            dependencies: [
                "XXFExtensions",
                .product(name: "Logging", package: "swift-log"),
                /// 可视化
                .product(name: "Pulse", package: "PulseCompat"),
                .product(name: "PulseUI", package: "PulseCompat"),
                .product(name: "PulseLogHandler", package: "PulseCompat"),
                .product(name: "PulseProxy", package: "PulseCompat"),
            ]
        ),
        .target(
            name: "XXFFlow",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
            ]
        ),
        .target(
            name: "XXFHttp",
            dependencies: [
                .product(name: "Moya", package: "Moya"),
                .product(name: "RxMoya", package: "Moya"),
                /// 流的拓展
                "XXFFlow",
            ]
        ),
        .target(
            name: "XXFDatabase"
        ),
        .target(
            name: "XXFDatabaseGrdb",
            dependencies: [
                "XXFDatabase",
                "XXFExtensions",
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .target(
            name: "XXFDi",
            dependencies: [
                .product(name: "Factory", package: "Factory"),
                .product(name: "FactoryKit", package: "Factory"),
            ]
        ),
        .target(
            name: "XXFHud",
            dependencies: [
                "XXFFlow",
                // .product(name: "ProgressHUD", package: "ProgressHUD"),
            ]
        ),
        .target(
            name: "XXFHudMac"),
        .target(
            name: "XXFArch",
            dependencies: [
                "XXFExtensions",
                "XXFLog",
                "XXFFlow",
                "XXFHttp",
                "XXFHud",
                "XXFPerformance",
                "XXFSpeed",
            ]
        ),
        .target(
            name: "XXFPerformance"
        ),
        .testTarget(
            name: "xxf_iosTests",
            dependencies: ["XXFLog"]
        ),
    ]
)
