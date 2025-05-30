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
            name: "XXFFlow",
            targets: ["XXFFlow"]
        ),
        .library(
            name: "XXFHttp",
            targets: ["XXFHttp"]
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
    ],
    dependencies: [
        // 第三方依赖写这里
        /// 新的跨平台日志库 比os.Logger更好用,能更好扩展
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.3"),
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", from: "7.0.0"),
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3"),
        .package(url: "https://github.com/kean/Pulse", from: "5.1.4"),
        .package(url: "https://github.com/kean/PulseLogHandler.git", from: "5.1.0"),
        // .package(url: "https://github.com/relatedcode/ProgressHUD", from: "14.1.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "XXFExtensions",
            dependencies: [
                .product(name: "SwifterSwift", package: "SwifterSwift"),
            ]
        ),
        .target(
            name: "XXFAppkit"
        ),
        .target(
            name: "XXFLog",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                /// 可视化
                .product(name: "Pulse", package: "Pulse"),
                .product(name: "PulseUI", package: "Pulse"),
                .product(name: "PulseLogHandler", package: "PulseLogHandler"),
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
            ]
        ),
        .testTarget(
            name: "xxf_iosTests",
            dependencies: ["XXFLog"]
        ),
    ]
)
