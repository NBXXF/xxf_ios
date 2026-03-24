//
//  FirebaseEventChannel+Example.swift
//  xxf_ios
//  FirebaseEventChannel 使用示例
//  Created by xxf on 2019/5/28.
//

import Foundation
import XXFEventReporter
import XXFEventReporterFirebase

// MARK: - 使用示例

/*

 // 1. 首先在 AppDelegate 中初始化 Firebase（必须在注册渠道之前）

 import FirebaseCore

 func application(_ application: UIApplication,
                  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
     // 初始化 Firebase
     FirebaseApp.configure()

     // 设置事件上报
     setupEventReporter()

     return true
 }

 // 2. 配置事件上报渠道

 import XXFEventReporter
 import XXFEventReporterFirebase

 func setupEventReporter() {
     // 创建并注册 Firebase 渠道
     let firebaseChannel = FirebaseEventChannel.default()
     EventReporter.shared.registerChannel(firebaseChannel)

     // 开始上报事件
     EventReporter.report("app_launch")
     EventReporter.report("button_click", params: ["button_name": "submit"])
 }

 */

// MARK: - 高级配置示例

/*

 // 关闭自动名称清理（假设你的事件名已符合 Firebase 规范）
 let firebaseChannel = FirebaseEventChannel(autoSanitize: false)

 // 注册渠道
 EventReporter.shared.registerChannel(firebaseChannel)

 */

// MARK: - 批量上报示例

/*

 // 批量上报多个事件
 let events = [
     ("page_view", ["page": "home"]),
     ("button_click", ["button": "buy_now"]),
     ("purchase", ["item_id": "12345", "value": 99.99])
 ]

 EventReporter.shared.reportEvents(events)

 // 或者异步批量上报
 EventReporter.shared.reportEventsAsync(events)

 */
