//
//  Observable+Create.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/26.
//

import Dispatch
import RxSwift

public extension Observable {
    /// 类似 RxJava 的 fromCallable：同步执行闭包并发出结果或错误
    static func fromCallable(_ callable: @escaping () throws -> Element) -> Observable<Element> {
        return Observable.deferred {
            do {
                return try Observable.just(callable())
            } catch {
                return Observable.error(error)
            }
        }
    }

//    /// 把 async 函数转换成 Observable，支持抛错
//    /// - Parameter asyncFunction: 无参数的 async 抛错函数，返回 Element
    //   public static func fromAsync(
//        on scheduler: SchedulerType = MainScheduler.instance,
//        _ asyncFunction: @escaping () async throws -> Element
//    ) -> Observable<Element> {
//        return Observable.create { observer in
//            let task = Task {
//                do {
//                    let result = try await asyncFunction()
//                    await MainActor.run {
//                        _ = scheduler.schedule(()) { _ in
//                            observer.onNext(result)
//                            observer.onCompleted()
//                            return Disposables.create()
//                        }
//                    }
//                } catch {
//                    await MainActor.run {
//                        _ = scheduler.schedule(()) { _ in
//                            observer.onError(error)
//                            return Disposables.create()
//                        }
//                    }
//                }
//            }
//
//            return Disposables.create {
//                task.cancel()
//            }
//        }
//    }
}

public extension Observable where Element == Void {
    /// fromAction 返回 Observable<Void>，执行无返回值同步代码后发出完成事件
    static func fromAction(_ action: @escaping () throws -> Void) -> Observable<Void> {
        return Observable.deferred {
            do {
                try action()
                return Observable.just(())
            } catch {
                return Observable.error(error)
            }
        }
    }
}
