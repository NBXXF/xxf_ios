//
//  XXFFlow.swift
//  xxf_ios
//
//  Created by xxf on 5/29.
//

@_exported import RxBlocking
@_exported import RxCocoa
@_exported import RxSwift

/**
 import RxSwift

 // 不要自动打印订阅栈（可选）
 Hooks.recordCallStackOnError = false

 // 全局未捕获错误处理器：所有漏写 onError 的错误都会走这里
 Hooks.defaultErrorHandler = { subscriptionCallStack, error in
     // 1) 你可以统一上报日志
     print("🔶 全局捕获未处理的错误：", error)
     // 2) 或者静默吞掉，或给用户弹个吐司
 }
 这样当你在任意一个 Observable/Single/Completable/… 上只调用了 subscribe(onNext:)、drive(onNext:) 而没写 onError 时，RxSwift 不再触发 fatalError 崩溃，而是把错误分发给上面注册的 defaultErrorHandle
 */
