/// RxSwift Error 扩展
///
/// 用于对 `RxError` 进行语义化判断，避免在业务代码中直接使用
/// `if case` 或强转判断，提高可读性与可维护性。
///
/// 使用场景：
/// - 在 subscribe/onError 中进行错误分类处理
/// - 忽略特定错误（如 disposed）
/// - 上报埋点时区分错误类型
///
/// 示例：
/// ```swift
/// observable
///     .subscribe(onError: { error in
///         if error.isRxDisposedError {
///             return // 忽略
///         }
///     })
/// ```
///
/// 注意：
/// - 仅对 `RxError` 生效，其他 Error 类型均返回 false
/// - 不建议用于业务强依赖判断（避免与 Rx 内部实现耦合）
///
/// Author: xxf
public extension Error {
    /// 是否为 RxSwift 的 disposed 错误
    ///
    /// 触发场景：
    /// - Observable 被 dispose（如 DisposeBag 释放）
    /// - 手动调用 dispose()
    ///
    /// 常见用途：
    /// - 忽略该错误（属于正常生命周期行为）
    var isRxDisposedError: Bool {
        guard let rxError = self as? RxError else { return false }
        if case .disposed = rxError {
            return true
        }
        return false
    }

    /// 是否为 RxSwift 的多元素错误（期望单个元素却收到多个）
    ///
    /// 触发场景：
    /// - 使用 `single()`、`asSingle()` 等操作符时，
    ///   上游发送了多个元素
    ///
    /// 常见用途：
    /// - 数据异常监控
    /// - Debug 流程错误
    var isRxMoreThanOneElementError: Bool {
        guard let rxError = self as? RxError else { return false }
        if case .moreThanOneElement = rxError {
            return true
        }
        return false
    }

    /// 是否为 RxSwift 的超时错误
    ///
    /// 触发场景：
    /// - 使用 `timeout` 操作符
    /// - 在指定时间内未收到事件
    ///
    /// 常见用途：
    /// - 网络请求超时处理
    /// - 提示用户重试
    var isRxTimeoutError: Bool {
        guard let rxError = self as? RxError else { return false }
        if case .timeout = rxError {
            return true
        }
        return false
    }

    /// 是否为 RxSwift 的参数越界错误
    ///
    /// 触发场景：
    /// - 操作符内部参数非法（如 index 越界）
    ///
    /// 常见用途：
    /// - Debug 数据问题
    /// - 防御性日志记录
    var isRxArgumentOutOfRangeError: Bool {
        guard let rxError = self as? RxError else { return false }
        if case .argumentOutOfRange = rxError {
            return true
        }
        return false
    }
}
