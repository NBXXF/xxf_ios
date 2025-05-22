// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xxf_ios",
    platforms: [
          .iOS(.v13),
          .macOS(.v13)
      ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "xxf_log",
            targets: ["xxf_log"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "xxf_log"),
        .testTarget(
            name: "xxf_iosTests",
            dependencies: ["xxf_log"]
        ),
    ]
)
