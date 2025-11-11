//
//  Observable+Create.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//

import Dispatch
import RxSwift

public extension Observable {
    /// 类似 RxJava 的 fromCallable：同步执行闭包并发出结果或错误
    static func fromCallable(_ callable: @escaping () throws -> Element) -> Observable<Element> {
        return Observable.create { observer in
            let disposable = BooleanDisposable()

            autoreleasepool {
                guard !disposable.isDisposed else { return }
                do {
                    let result = try callable()
                    if !disposable.isDisposed {
                        observer.onNext(result)
                        observer.onCompleted()
                    }
                } catch {
                    if !disposable.isDisposed {
                        observer.onError(error)
                    }
                }
            }

            return disposable
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
    /// 类似 RxJava 的 fromAction：同步执行闭包并发出 Void 或错误
    static func fromAction(_ action: @escaping () throws -> Void) -> Observable<Void> {
        return Observable<Void>.create { observer in
            let disposable = BooleanDisposable()

            autoreleasepool {
                guard !disposable.isDisposed else { return }
                do {
                    try action()
                    if !disposable.isDisposed {
                        observer.onNext(())
                        observer.onCompleted()
                    }
                } catch {
                    if !disposable.isDisposed {
                        observer.onError(error)
                    }
                }
            }

            return disposable
        }
    }
}
