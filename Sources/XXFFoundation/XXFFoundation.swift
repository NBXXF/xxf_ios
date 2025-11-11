//
//  XXFFoundation.swift
//  xxf_ios
//
//  Created by xxf on 7/30.
//

/// 继续导出
@_exported import Foundation

/// Swift Collections
/// 提供高性能、扩展的集合类型，如 `Deque`、`OrderedSet`、`OrderedDictionary`，
/// 用于替代或增强标准库中的 Array / Set / Dictionary 等。
@_exported import Collections

/// Swift Algorithms
/// 提供丰富的序列处理算法扩展，如 `chunked(by:)`、`combinations(ofCount:)`、
/// `interspersed(with:)` 等，适用于 Array / Sequence 等类型的链式操作。
@_exported import Algorithms

/// Swift Numerics
/// 提供扩展的数学数值类型，如 `Complex` 复数、`Real` 实数协议、`BigInt` 任意精度整数，
/// 用于科学计算、高精度运算等场景。
@_exported import Numerics

/**
 import Atomics 的主要作用：提供原子变量和原子操作 API
 解决多线程日志写入中计数器的 线程安全问题
 配合 batch 计数器，可以安全地每 N 条日志触发一次清理

 let counter = ManagedAtomic(0)
 let current = counter.wrappingIncrementThenLoad(ordering: .relaxed)
 */
@_exported import Atomics

@_exported import Logging
