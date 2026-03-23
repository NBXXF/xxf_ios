// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xxf_ios",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
//        .library(
//            name: "XXFAppkit",
//            targets: ["XXFAppkit"]
//        ),
//        .library(
//            name: "XXFFoundation",
//            targets: ["XXFFoundation"]
//        ),
        // 不对外暴露
//        .library(
//            name: "XXFExtensions",
//            targets: ["XXFExtensions"]
//        ),
//        .library(
//            name: "XXFLog",
//            targets: ["XXFLog"]
//        ),
//        .library(
//            name: "XXFSpeed",
//            targets: ["XXFSpeed"]
//        ),
//        .library(
//            name: "XXFFlow",
//            targets: ["XXFFlow"]
//        ),
//        .library(
//            name: "XXFHttp",
//            targets: ["XXFHttp"]
//        ),
//        .library(
//            name: "XXFDatabase",
//            targets: ["XXFDatabase"]
//        ),
        .library(
            name: "XXFDatabaseGrdb",
            targets: ["XXFDatabaseGrdb"]
        ),
//        .library(
//            name: "XXFCache",
//            targets: ["XXFCache"]
//        ),
//        .library(
//            name: "XXFDi",
//            targets: ["XXFDi"]
//        ),
//        .library(
//            name: "XXFHud",
//            targets: ["XXFHud"]
//        ),
        .library(
            name: "XXFHudiOS",
            targets: ["XXFHudiOS"]
        ),
        .library(
            name: "XXFHudMac",
            targets: ["XXFHudMac"]
        ),
        .library(
            name: "XXFArch",
            targets: ["XXFArch"]
        ),
//        .library(
//            name: "XXFPerformance",
//            targets: ["XXFPerformance"]
//        ),
//        .library(
//            name: "XXFBus",
//            targets: ["XXFBus"]
//        ),
//        .library(
//            name: "XXFJson",
//            targets: ["XXFJson"]
//        ),
        .library(
            name: "XXFServer",
            targets: ["XXFServer"]
        ),
//        .library(
//            name: "XXFKeychain",
//            targets: ["XXFKeychain"]
//        ),
        .library(
            name: "XXFTrackerBugsnag",
            targets: ["XXFTrackerBugsnag"]
        ),
        .library(
            name: "XXFTrackerSentry",
            targets: ["XXFTrackerSentry"]
        ),
        .library(
            name: "XXFRouter",
            targets: ["XXFRouter"]
        ),
        .library(
            name: "XXFImageEditor",
            targets: ["XXFImageEditor"]
        ),
        .library(
            name: "XXFImageEditorBrightroom",
            targets: ["XXFImageEditorBrightroom"]
        ),
        .library(
            name: "XXFKeyboard",
            targets: ["XXFKeyboard"]
        ),
        .library(
            name: "XXFCompress",
            targets: ["XXFCompress"]
        )
    ],
    dependencies: [
        // 第三方依赖写这里
        /// 新的跨平台日志库 比os.Logger更好用,能更好扩展
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.3"),
        .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.1"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.2.1"),
        .package(url: "https://github.com/apple/swift-numerics.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.3.0"),

        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.7.0"),
        .package(url: "https://github.com/RxSwiftCommunity/RxKeyboard.git", from: "2.0.0"),
        .package(url: "https://github.com/SwifterSwift/SwifterSwift.git", from: "7.0.0"),
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.3"),
        .package(url: "https://github.com/NBXXF/PulseCompat", .upToNextMajor(from: "4.4.2")),
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.5.3"),
        .package(url: "https://github.com/groue/GRDB.swift", .upToNextMajor(from: "7.0.0")),
        /// 目前支持arm.不支持x86
        /// .package(url: "https://github.com/NBXXF/XXFHighwayHash.swift.git", from: "1.0.0"),
        .package(url: "https://github.com/NBXXF/XXFXXHash.swift.git", from: "1.0.0"),
        // .package(url: "https://github.com/kstenerud/KSCrash.git", from: "2.2.0"),

        /// 服务器开发框架
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(url: "https://github.com/vapor/websocket-kit.git", from: "2.16.1"),
        // .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.26.1"),///大规模请求其他api,NIO实现

        /// hud组件
        // .package(url: "https://github.com/relatedcode/ProgressHUD", from: "14.1.3"),

        /// 免费的错误统计
        .package(url: "https://github.com/bugsnag/bugsnag-cocoa", from: "6.32.2"),
        // 仅仅支持ios
        // .package(url: "https://github.com/bugsnag/bugsnag-cocoa-performance.git", exact: "1.14.0"),
        .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.56.2"),

        // 图片库
        .package(url: "https://github.com/kean/Nuke.git", from: "12.9.0"),
        // toast
        .package(url: "https://github.com/BastiaanJansen/toast-swift", from: "2.1.3"),
        // refresh
        .package(url: "https://github.com/CoderMJLee/MJRefresh.git",from: "3.7.9"),
        // disk cache
        .package(url: "https://github.com/hyperoslo/Cache.git", from: "7.4.0"),
        // 路由框架底层
        .package(url: "https://github.com/devxoul/URLNavigator.git", from: "2.5.1"),
        // 自动布局框架
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),

        // 图片编辑器（fork 版，修复了官方 2.x 未声明 macOS 导致 Verge 11.x 报错的问题）
        .package(url: "https://github.com/NBXXF/Brightroom.git", from: "2.10.2"),

        // 性能监控（FPS、CPU、内存）
        .package(url: "https://github.com/dani-gavrilov/GDPerformanceView-Swift.git", from: "2.1.1")
    ],
    targets: [
        .target(
            name: "XXFSwiftFormat"
        ),
        .target(
            name: "XXFAdapter",
            dependencies: [
                .product(name: "Collections", package: "swift-collections")
            ]
        ),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "XXFExtensions",
            dependencies: [
                .product(name: "SwifterSwift", package: "SwifterSwift"),
                "XXFSpeed"
            ]
        ),
        .target(
            name: "XXFFoundation",
            dependencies: [
                "XXFSpeed",
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),
//        .target(
//            name: "XXFAppkit",
//            dependencies: [
//                "XXFViewModel",
//                "XXFImageLoader",
//                "XXFImageNukeLoader",
//            ]
//        ),
        .target(
            name: "XXFViewModel",
            dependencies: [
                "XXFFoundation",
                "XXFFlow"
            ]
        ),
        .target(
            name: "XXFSpeed",
            dependencies: [
                // .product(name: "XXFHighwayHash", package: "XXFHighwayHash.swift"),
                .product(name: "XXFXXHash", package: "XXFXXHash.swift")
            ]
        ),
        .target(
            name: "XXFLog",
            dependencies: [
                "XXFFoundation",
                .product(name: "Logging", package: "swift-log"),

                /// 可视化
                .product(name: "Pulse", package: "PulseCompat"),
                .product(name: "PulseUI", package: "PulseCompat"),
                .product(name: "PulseLogHandler", package: "PulseCompat"),
                .product(name: "PulseProxy", package: "PulseCompat")
                // .product(name: "Installations", package: "KSCrash"),
            ]
        ),
        .target(
            name: "XXFFlow",
            dependencies: [
                "XXFFoundation",
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxBlocking", package: "RxSwift") // ✅ 加上这个
            ]
        ),
        .target(
            name: "XXFHttp",
            dependencies: [
                .product(name: "Moya", package: "Moya"),
                .product(name: "RxMoya", package: "Moya"),
                "XXFDataSource",
                "XXFFlow",
                "XXFJson",
                "XXFSpeed",
                "XXFCache",
                /// 日志
                .product(name: "Pulse", package: "PulseCompat")
            ]
        ),
        .target(
            name: "XXFDataSource"
        ),
        .target(
            name: "XXFDatabase",
            dependencies: [
                "XXFDataSource",
                "XXFSpeed",
                .product(name: "Algorithms", package: "swift-algorithms")
            ]
        ),
        .target(
            name: "XXFDatabaseGrdb",
            dependencies: [
                "XXFDatabase",
                "XXFFoundation",
                .product(name: "GRDB", package: "GRDB.swift")
            ]
        ),
        .target(
            name: "XXFCache",
            dependencies: [
                "XXFDataSource",
                .product(name: "Cache", package: "Cache")
            ]
        ),
        .target(
            name: "XXFDi",
            dependencies: [
                .product(name: "Factory", package: "Factory"),
                .product(name: "FactoryKit", package: "Factory")
            ]
        ),
        .target(
            name: "XXFHud",
            dependencies: [
                "XXFFlow",
                "XXFFoundation",
                .product(name: "Toast", package: "toast-swift",condition: .when(platforms: [.iOS])),
//                .product(name: "XXFHudiOS", package: "XXFHudiOS",condition: .when(platforms: [.iOS])),
              
                // .product(name: "ProgressHUD", package: "ProgressHUD"),
            ]
        ),
        .target(
            name: "XXFHudiOS"),
        .target(
            name: "XXFHudMac"),
        .target(
            name: "XXFArch",
            dependencies: [
                "XXFFoundation",
                "XXFExtensions",
                "XXFLog",
                "XXFFlow",
                "XXFHttp",
                "XXFDi",
                "XXFHud",
                "XXFPerformance",
                "XXFSpeed",
                "XXFCache",
                "XXFDatabase",
                "XXFBus",
                "XXFJson",
                "XXFKeyboard",
                "XXFTracker",
                "XXFKeychain",
                "XXFIdentifier",
                "XXFReusable",
                "XXFRefreshable",
                "XXFRouter",
                "XXFViewModel",
                "XXFImageLoader",
                "XXFImageNukeLoader",
                "XXFImageEditor",
                "XXFImageEditorBrightroom",
                "XXFAdapter",
                "XXFUIKit",
                "XXFSwiftFormat",
                "XXFCompress",
                // 自动布局框架
                .product(name: "SnapKit", package: "SnapKit")
            ],
            swiftSettings: [
                .define("IOS", .when(platforms: [.iOS]))
            ]
        ),
        .target(
            name: "XXFPerformance",
            dependencies: [
                .product(name: "GDPerformanceView-Swift", package: "GDPerformanceView-Swift", condition: .when(platforms: [.iOS]))
            ]
        ),
        .target(
            name: "XXFReusable"
        ),
        .target(
            name: "XXFRefreshable",
            dependencies: [
                .product(name: "MJRefresh", package: "MJRefresh", condition: .when(platforms: [.iOS])),
                "XXFFlow"
            ]
        ),
        .target(
            name: "XXFBus",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift") // ✅ 这个必须单独写
            ]
        ),
        .target(
            name: "XXFJson",
            dependencies: [
                "XXFFoundation"
            ]
        ),
        .target(
            name: "XXFServer",
            dependencies: [
                "XXFFoundation",
                "XXFJson",
                // 接收http请求
                .product(name: "Vapor", package: "vapor"),
                // 接收socket
                .product(name: "WebSocketKit", package: "websocket-kit"),
                // 高并发请求其他http
                // .product(name: "AsyncHTTPClient", package: "async-http-client"),
                /// 日志
                .product(name: "Pulse", package: "PulseCompat")
            ]

        ),
        .target(
            name: "XXFTracker"
        ),
        .target(
            name: "XXFUIKit"
        ),
        .target(
            name: "XXFKeychain"
        ),
        .target(
            name: "XXFIdentifier",
            dependencies: [
                "XXFKeychain"
            ]
        ),
        .target(
            name: "XXFImage"
        ),
        .target(
            name: "XXFImageLoader",
            dependencies: [
                "XXFFoundation",
                "XXFImage"
            ]
        ),
        .target(
            name: "XXFImageNukeLoader",
            dependencies: [
                "XXFImageLoader",
                .product(name: "Nuke", package: "Nuke", condition: .when(platforms: [.iOS]))
            ]
        ),
        .target(
            name: "XXFTrackerBugsnag",
            dependencies: [
                "XXFTracker",
                // 把 Bugsnag 框架添加到你的 Target
                .product(name: "Bugsnag", package: "bugsnag-cocoa")
                // .product(name: "BugsnagPerformance", package: "bugsnag-cocoa-performance"),
            ]
        ),
        .target(
            name: "XXFTrackerSentry",
            dependencies: [
                "XXFTracker",
                .product(name: "Sentry", package: "sentry-cocoa")
            ]
        ),
        // MARK: - 路由框架
        .target(
            name: "XXFRouter",
            dependencies: [
                .product(name: "URLNavigator", package: "URLNavigator"),
                .product(name: "URLMatcher", package: "URLNavigator")
            ]
        ),
        // MARK: - 图片编辑器（抽象层，无第三方依赖）
        .target(
            name: "XXFImageEditor"
        ),
        // MARK: - 图片编辑器（Brightroom 实现，iOS only）
        // Brightroom 的 Package.swift 中 macOS 版本声明与其依赖 Verge 不一致
        // 使用 .when(platforms: [.iOS]) 限制仅在 iOS 上链接 Brightroom，避免 macOS 构建报错
        .target(
            name: "XXFImageEditorBrightroom",
            dependencies: [
                "XXFImageEditor",
                .product(name: "BrightroomUI", package: "Brightroom", condition: .when(platforms: [.iOS])),
                .product(name: "BrightroomEngine", package: "Brightroom", condition: .when(platforms: [.iOS]))
            ]
        ),
        // MARK: - 图片压缩（Luban 风格，微信压缩算法）
        .target(
            name: "XXFCompress"
        ),
        .target(
            name: "XXFKeyboard",
            dependencies: [
                "XXFFoundation",
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxKeyboard", package: "RxKeyboard", condition: .when(platforms: [.iOS])),
                .product(name: "SnapKit", package: "SnapKit", condition: .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "xxf_iosTests",
            dependencies: ["XXFLog", "XXFCache"]
        )
    ]
)
