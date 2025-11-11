//
//  Task.swift
//  xxf_ios
//
//  Created by xxf on 6/14.
//
/// 解决swift Task和Vapor Task 名字同名冲突
import struct _Concurrency.Task // 这个导入是隐式的

public typealias SwiftTask = _Concurrency.Task
