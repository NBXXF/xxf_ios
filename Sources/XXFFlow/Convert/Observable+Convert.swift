//
//  Observable+Convert.swift
//  xxf_ios
//
//  Created by xxf on 5/26.
//
import RxSwift

public extension ObservableType {
    /**
     转换函数                                    输出类型                         对空信号（不发元素）                        对多信号（多个元素）                              错误处理行为                                                      备注
     --------------------------------------------------------------------------------------------------------------------------------------------------------
     asSingleSafe() (你的封装)         Single<[Element]>        返回 Single，发出空数组 []             收集所有元素组成数组发出一次                直接传递错误，Single 会 error 终止                    只收集元素为数组，无错误恢复机制
     asSingle() (RxSwift 自带)          Single<Element>             如果没元素，Single 会 error               如果多元素，会报错（只能发一个元素） 直接传递错误，Single 会 error 终止                     只能用于发单个元素的 Observable
     asSignal(onErrorJustReturn:)   Signal<Element>            转换为空 Signal，不发元素完成         多个元素逐个转发                                      发生错误时发指定默认元素，然后完成               保证 Signal 无错误，适合 UI 绑定
     asSignal(onErrorSignalWith:)   Signal<Element>            转换为空 Signal，不发元素完成         多个元素逐个转发                                      发生错误时切换到备用 Signal 继续发事件            灵活的错误恢复方式
     asSignal(onErrorRecover:)      Signal<Element>             转换为空 Signal，不发元素完成        多个元素逐个转发                                      发生错误时调用闭包生成备用 Signal 继续发事件 可根据错误动态决定如何恢复

     */

    /// observable 转换single 有如下情况
    /// 1. 没有数据（空）
    /// 2. 有一个数据
    /// 3. 有多个数据
    /// - Returns: 返回0个或者多个元素的数组,错误进行传递
    func asSingleSafe() -> Single<[Element]> {
        return toArray()
    }
}
