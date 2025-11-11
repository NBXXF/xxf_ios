//
//  BaseResponseDto.swift
//  xxf_ios
//  通用响应模型,业务实现类可以通过CodingKeys自定义映射序列化和反序列化过程
//  Created by xxf on /6/2.
//

public protocol BaseResponseDto: Codable {
    associatedtype DataType: Codable
    var code: Int { get set }
    var data: DataType? { get set }
    var msg: String? { get set }
    func isSuccess() -> Bool
}
