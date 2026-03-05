//
//  XXFRouter.swift
//  XXFRouter
//
//  XXFRouter - 功能完整的 iOS/macOS 路由框架
//  基于 URLNavigator 底层实现，参考 DRouter 架构设计
//
//  主要特性：
//  - 基于 URLNavigator 的高效 URL 模式匹配
//  - 支持路径参数和查询参数解析
//  - 强大的拦截器机制（支持登录检查、权限验证等）
//  - 服务发现（SPI机制）
//  - 降级策略（路由未找到时的备选方案）
//  - 路由回调和监听
//  - 防抖导航（防止重复点击）
//  - Async/Await 支持
//  - 支持 iOS 和 macOS
//
//  Created by XXF on 2024
//

import Foundation
@_exported import URLNavigator

// MARK: - 版本信息

/// XXFRouter 版本号
public let XXFRouterVersion = "1.0.0"

// MARK: - 快速访问

/// 全局路由器快速访问
@MainActor
public var router: Router { Router.shared }

// MARK: - 类型导出

// Core
public typealias XXFRouter = Router
public typealias XXFRouteContext = RouteContext
public typealias XXFRouteFlags = RouteFlags
public typealias XXFRouteOptions = RouteOptions
public typealias XXFRouteError = RouteError
public typealias XXFNavigationType = NavigationType

// Routable
public typealias XXFRoutable = Routable
public typealias XXFRouteFactory = RouteFactory
public typealias XXFRouteHandler = RouteHandler

// Registry
public typealias XXFRouteRegistry = RouteRegistry

// Interceptor
public typealias XXFRouteInterceptor = RouteInterceptor
public typealias XXFInterceptorChain = InterceptorChain
public typealias XXFInterceptorResult = InterceptorResult
public typealias XXFInterceptorPriority = InterceptorPriority

// Service
public typealias XXFServiceProtocol = ServiceProtocol
public typealias XXFServiceRegistry = ServiceRegistry

// Degradation
public typealias XXFDegradationHandler = DegradationHandler
public typealias XXFDegradationResult = DegradationResult
public typealias XXFDegradationStrategy = DegradationStrategy

// Result
public typealias XXFRouteResult = RouteResult
public typealias XXFRouteCallback = RouteCallback
public typealias XXFRouteListener = RouteListener
public typealias XXFRouteEvent = RouteEvent

// Navigator
public typealias XXFRouteNavigator = RouteNavigator

// Module
public typealias XXFRouteModule = RouteModule
public typealias XXFRouteGroup = RouteGroup

// MARK: - 使用示例文档

/*

 # XXFRouter 使用指南

 ## 1. 基础配置

 ```swift
 // 在 AppDelegate 或 App 启动时配置
 func application(_ application: UIApplication, didFinishLaunchingWithOptions...) -> Bool {

     // 配置路由器
     Router.shared.configure { config in
         config.loggingEnabled = true  // 开发环境开启日志
         config.degradationEnabled = true
     }

     // 注册路由
     setupRoutes()

     // 注册拦截器
     setupInterceptors()

     // 注册服务
     setupServices()

     return true
 }
 ```

 ## 2. 路由注册

 ### 2.1 使用 Routable 协议

 ```swift
 class ProfileViewController: UIViewController, Routable {
     static var routePattern: String { "app://profile/<userId>" }
     static var routeFlags: RouteFlags { .requiresLogin }

     private var userId: String = ""

     required init?(context: RouteContext) {
         super.init(nibName: nil, bundle: nil)
         self.userId = context.string(for: "userId") ?? ""
     }

     required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
     }
 }

 // 注册
 Router.shared.register(ProfileViewController.self)
 ```

 ### 2.2 使用闭包注册

 ```swift
 Router.shared.register(pattern: "app://settings", flags: .requiresLogin) { context in
     let vc = SettingsViewController()
     return vc
 }
 ```

 ### 2.3 注册处理器（不创建视图控制器）

 ```swift
 Router.shared.registerHandler(pattern: "app://share") { context in
     let url = context.string(for: "url") ?? ""
     ShareManager.share(url: url)
     return true
 }
 ```

 ### 2.4 模块化注册

 ```swift
 struct UserModule: RouteModule {
     static func register(to router: Router) {
         router.register(ProfileViewController.self)
         router.register(SettingsViewController.self)

         router.group(name: "account", prefix: "app://account", sharedFlags: .requiresLogin) { group in
             group.register(pattern: "wallet") { _ in WalletViewController() }
             group.register(pattern: "orders") { _ in OrdersViewController() }
         }
     }
 }

 // 注册模块
 Router.shared.registerModule(UserModule.self)
 ```

 ## 3. 拦截器

 ### 3.1 使用内置拦截器

 ```swift
 // 登录拦截器
 let loginInterceptor = LoginCheckInterceptor(
     loginURL: "app://login",
     isLoggedIn: { UserManager.shared.isLoggedIn }
 )
 Router.shared.registerInterceptor(loginInterceptor)

 // VIP 拦截器
 let vipInterceptor = VIPCheckInterceptor(
     purchaseURL: "app://vip/purchase",
     isVIP: { UserManager.shared.isVIP }
 )
 Router.shared.registerInterceptor(vipInterceptor)
 ```

 ### 3.2 自定义拦截器

 ```swift
 class CustomInterceptor: RouteInterceptor {
     var priority: Int { InterceptorPriority.high }
     var targetFlags: RouteFlags { [.requiresLogin, .custom(0)] }

     func intercept(context: RouteContext, chain: InterceptorChain) {
         if someCondition {
             chain.proceed()
         } else {
             chain.reject(reason: "Custom rejection reason")
         }
     }
 }
 ```

 ## 4. 服务（SPI）

 ```swift
 // 定义服务协议
 protocol UserServiceProtocol: ServiceProtocol {
     func getCurrentUser() -> User?
     func logout()
 }

 // 实现服务
 class UserServiceImpl: UserServiceProtocol {
     static var serviceName: String { "UserService" }
     static var serviceAlias: [String] { ["user"] }

     required init() {}

     func getCurrentUser() -> User? { ... }
     func logout() { ... }
 }

 // 注册服务
 Router.shared.registerService(UserServiceImpl.self, for: UserServiceProtocol.self)

 // 获取服务
 if let userService: UserServiceProtocol = Router.shared.service() {
     let user = userService.getCurrentUser()
 }
 ```

 ## 5. 降级策略

 ```swift
 // 设置 404 页面
 Router.shared.setNotFoundPage { context in
     let vc = NotFoundViewController()
     vc.failedURL = context.url
     return vc
 }

 // 外部链接降级
 Router.shared.registerDegradation(ExternalLinkDegradationHandler())

 // 自定义降级
 Router.shared.registerDegradation(URLPatternDegradationHandler(pattern: "http") { context in
     // 打开 Safari
     if let url = URL(string: context.url) {
         UIApplication.shared.open(url)
     }
     return .handled
 })
 ```

 ## 6. 导航

 ```swift
 // 基础导航
 Router.shared.navigate(to: "app://profile/123")

 // 带参数导航
 Router.shared.navigate(
     to: "app://profile/123",
     extraParameters: ["from": "home"]
 )

 // 带回调导航
 Router.shared.navigate(to: "app://profile/123") { result in
     switch result {
     case .success(let vc):
         print("Navigation success: \(vc)")
     case .failure(let error):
         print("Navigation failed: \(error)")
     }
 }

 // Push/Present
 Router.shared.push(to: "app://profile/123")
 Router.shared.present(to: "app://profile/123")

 // 从视图控制器导航
 self.navigate(to: "app://profile/123")
 self.push(to: "app://profile/123")
 self.present(to: "app://profile/123")

 // URL 构建器
 routeURL(scheme: "app")
     .path("profile")
     .path("123")
     .query("tab", "posts")
     .navigate()
 ```

 ## 7. 调试

 ```swift
 // 打印路由表
 Router.shared.printRouteTable()

 // 检查路由是否存在
 if Router.shared.canRoute(to: "app://profile/123") {
     // ...
 }

 // 获取视图控制器（不导航）
 if let vc = Router.shared.viewController(for: "app://profile/123") {
     // ...
 }
 ```

 */
