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
            name: "XXFLog",
            targets: ["XXFLog"]
        ),
        .library(
            name: "XXFFlow",
            targets: ["XXFFlow"]
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
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.0.0"),
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", from: "7.0.0")
        // .package(url: "https://github.com/relatedcode/ProgressHUD", from: "14.1.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "XXFExtensions",
            dependencies: [
                .product(name: "SwifterSwift", package: "SwifterSwift")
            ]
        ),
        .target(
            name: "XXFLog"),
        .target(
            name: "XXFFlow",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
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
                "XXFLog",
                "XXFFlow",
                "XXFHud",
            ]
        ),
        .testTarget(
            name: "xxf_iosTests",
            dependencies: ["XXFLog"]
        ),
    ]
)
