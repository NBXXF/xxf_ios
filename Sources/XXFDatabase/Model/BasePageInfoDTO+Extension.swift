//
//  BasePageInfoDTO+Extension.swift
//  xxf_ios
//  支持泛型转换和拷贝扩展
//  Created by xxf on 7/11.
//

public extension BasePageInfoDTO {
    /// 将分页数据中的元素映射（转换）成另一种类型，返回新的分页对象
    ///
    /// - Parameter transform: 一个闭包，将当前分页数据元素 `T` 转换为新类型 `U`
    /// - Returns: 包含转换后元素列表的 `BasePageInfoDTO<U>` 新对象，分页信息保持不变
    ///
    /// 例如，将 DTO 类型分页转换为 ViewModel 类型分页
    func map<U>(_ transform: (T) -> U) -> BasePageInfoDTO<U> {
        return BasePageInfoDTO<U>(
            pageNum: pageNum,
            pageSize: pageSize,
            hasNextPage: hasNextPage,
            total: total,
            list: list.map(transform)
        )
    }

    /// 复制当前分页数据，同时对元素执行转换，等价于调用 `map(_:)` 方法
    ///
    /// - Parameter transform: 将元素 `T` 转换为新类型 `U` 的闭包
    /// - Returns: 转换后的新分页对象 `BasePageInfoDTO<U>`
    ///
    /// 该方法只是 `map(_:)` 的别名，便于根据语义选择调用
    func copy<U>(_ transform: (T) -> U) -> BasePageInfoDTO<U> {
        return map(transform)
    }

    /// 拷贝当前分页对象，并转换为指定的子类类型
    ///
    /// - Parameter type: 目标子类类型，必须继承自 `BasePageInfoDTO<T>`
    /// - Returns: 新建的子类对象，字段值与当前对象完全相同
    ///
    /// 用于将基类分页对象转换为具体的子类实例，以便子类增加额外功能或字段
    func copyAs<U: BasePageInfoDTO<T>>(to _: U.Type) -> U {
        return U(
            pageNum: pageNum,
            pageSize: pageSize,
            hasNextPage: hasNextPage,
            total: total,
            list: list
        )
    }
}
