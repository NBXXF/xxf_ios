//
//  AppRoutes.swift
//  xxf_ios
//  业务封装注册表声明路由的地方
//  建议用拓展的方式写成内部类的概念,按业务模块分离
//  Created by xxf
//

public enum AppRoutes {}

/*
  用法建议：用拓展的方式写成内部类的概念,按业务模块分离
 extension AppRoutes {
     enum TestModule {
         /// test page
         static let testPage = "app://test"

         /// 用户个人主页
         /// - Parameter userId: 用户 ID
         static func testProfile(userId: String) -> String {
             "app://testProfile/\(userId)"
         }
     }
 }
 */
