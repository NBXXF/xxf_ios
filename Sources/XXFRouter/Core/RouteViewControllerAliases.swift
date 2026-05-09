//
//  RouteViewControllerAliases.swift
//  XXFRouter
//
//  路由视图控制器类型别名
//

#if canImport(UIKit)
import UIKit
/// 视图控制器类型别名
public typealias RouteViewController = UIViewController
/// 导航控制器类型别名
public typealias RouteNavigationController = UINavigationController
#elseif canImport(AppKit)
import AppKit
/// 视图控制器类型别名
public typealias RouteViewController = NSViewController
/// 导航控制器类型别名
public typealias RouteNavigationController = NSViewController
#endif

