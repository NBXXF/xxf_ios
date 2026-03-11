//
//  BaseHttpResult.swift
//  xxf_ios
//  通用网络返回模型协议
//
//  Created by xxf on /6/10.
//

// MARK: - BaseHttpResult 协议

/// 通用 HTTP 响应结果协议
///
/// 定义了网络请求返回数据的标准结构，包含状态码、数据体和消息字段。
/// 所有网络响应模型都应遵循此协议，以确保统一的数据处理方式。
///
/// ## 协议要求
/// - `DataType`: 响应数据的泛型类型，必须遵循 `Codable` 协议
/// - `code`: HTTP 业务状态码
/// - `data`: 响应数据体（可选）
/// - `msg`: 响应消息/错误信息（可选）
/// - `isSuccess()`: 判断请求是否成功的方法
///
/// ## 用法示例
///
/// ### 1. 定义通用响应 DTO
/// ```swift
/// class BaseResponseDTO<T: Codable>: BaseHttpResult {
///     typealias DataType = T
///
///     var data: T?
///     var code: Int
///     var msg: String?
///
///     func isSuccess() -> Bool {
///         return code == 200
///     }
///
///     required init(from decoder: Decoder) throws {
///         let container = try decoder.container(keyedBy: CodingKeys.self)
///         self.code = try container.decode(Int.self, forKey: .code)
///         self.msg = try? container.decode(String.self, forKey: .msg)
///
///         // 处理特殊状态码（如 401 未授权）
///         if self.code == 401 {
///             runMainThreadIfNeeded {
///                 // 跳转登录页面
///             }
///             return
///         }
///
///         guard isSuccess() else { return }
///         // key 缺失或值为 null → nil；类型不匹配 → throw（由 LoggingJSONDecoder 记录日志）
///         self.data = try container.decodeIfPresent(T.self, forKey: .data)
///     }
/// }
/// ```
///
/// ### 2. 定义具体业务数据模型
/// ```swift
/// struct UserInfo: Codable {
///     var userId: String
///     var userName: String
///     var avatar: String?
/// }
/// ```
///
/// ### 3. 网络请求中使用
/// ```swift
/// // 使用 Moya + RxSwift
/// provider.rx.request(.getUserInfo)
///     .mapModel(BaseResponseDTO<UserInfo>.self)
///     .subscribe(onSuccess: { response in
///         if response.isSuccess(), let user = response.data {
///             print("用户名: \(user.userName)")
///         } else {
///             print("请求失败: \(response.msg ?? "未知错误")")
///         }
///     })
///     .disposed(by: disposeBag)
/// ```
///
/// ### 4. 处理列表数据
/// ```swift
/// // 列表类型响应
/// provider.rx.request(.getUserList)
///     .mapModel(BaseResponseDTO<[UserInfo]>.self)
///     .subscribe(onSuccess: { response in
///         if let users = response.data {
///             users.forEach { print($0.userName) }
///         }
///     })
///     .disposed(by: disposeBag)
/// ```
///
public protocol BaseHttpResult: Codable {
    /// 响应数据的关联类型，必须遵循 Codable 协议
    associatedtype DataType: Codable

    /// 业务状态码
    /// - Note: 通常 200 表示成功，401 表示未授权，其他值表示各种业务错误
    var code: Int { get set }

    /// 响应数据体
    /// - Note: 当请求失败或无数据时可能为 nil
    var data: DataType? { get set }

    /// 响应消息/错误描述
    /// - Note: 成功时可能为空，失败时包含错误原因
    var msg: String? { get set }

    /// 判断请求是否成功
    /// - Returns: 如果业务处理成功返回 true，否则返回 false
    func isSuccess() -> Bool
}
