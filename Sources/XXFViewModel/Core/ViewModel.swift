//
//  ViewModel.swift
//  xxf_ios
//  viewModel层约束
//  Created by xxf on 8/14.
//

import Combine
import Foundation

// 所有 ViewModel 都遵循这个协议
// 同时支持combine, 但特性:优先支持rxswift 强大
public protocol ViewModel: AnyObject, ObservableObject {
    // 要求所有遵循者必须实现无参初始化器
    init()

    /// 推荐使用rx的状态机,优先维护
    /// var currentTag: Obs = 1. obs
}
