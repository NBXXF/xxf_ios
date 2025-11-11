//
//  RxCallAdapter.swift
//  xxf_ios
//
//  Created by xxf on 8/23.
//
import Moya
import RxSwift

/// RxSwift 请求适配器拦截器
public protocol RxCallAdapter {
    /// 拦截并处理 Rx 流 Observable/Single/Maybe
    ///
    /// - Parameters:
    ///   - observable: 待拦截的 Rx 流，类型为 `ObservableConvertibleType`，
    ///                 可以是 `Observable`、`Single`、`Maybe` 等。
    ///                 该参数为输入流，可在方法内进行链式操作或转换。
    ///   - target: 发起请求的目标对象，遵循 `TargetType` 协议，
    ///             一般用于获取请求信息（如 URL、方法、参数等）。
    ///
    /// - Returns: 返回一个处理后的 ObservableConvertibleType,类型一致
    ///            可以在返回前对流进行 map、catchError、retry 等操作。
    ///
    /// - Note:
    ///   1. 方法内不要阻塞线程，应保持异步非阻塞。
    ///   2. 适配器可被多个拦截器链式调用，实现统一请求处理逻辑。
    func adapt<O: ObservableConvertibleType>(_ observable: O, target: TargetType) -> O
}
