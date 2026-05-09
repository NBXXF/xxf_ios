//
//  NotFoundDegradationHandler.swift
//  xxf_ios
//
//  Created by xxf on 5/9.
//

/// 默认404页面降级处理器
public final class NotFoundDegradationHandler: DegradationHandler, @unchecked Sendable {
    public let name = "NotFoundDegradationHandler"
    public let priority: Int
    public let strategy: DegradationStrategy = .showDefaultPage

    private let pageFactory: @Sendable (RouteContext) -> RouteViewController

    /// 创建默认404降级处理器
    /// - Parameters:
    ///   - priority: 优先级
    ///   - pageFactory: 创建404页面的工厂闭包
    public init(
        priority: Int = -1000, // 最低优先级
        pageFactory: @escaping @Sendable (RouteContext) -> RouteViewController
    ) {
        self.priority = priority
        self.pageFactory = pageFactory
    }

    public func canHandle(context: RouteContext) -> Bool {
        return true
    }

    public func handle(context: RouteContext) -> DegradationResult {
        let viewController = pageFactory(context)
        return .viewController(viewController)
    }
}
