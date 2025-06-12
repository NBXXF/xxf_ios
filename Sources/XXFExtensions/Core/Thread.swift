//
//  Thread.swift
//  xxf_ios
//  线程相关
//  Created by trl on 6/12.
//

import Foundation

@inline(__always)
public func requireMainThread() throws {
    try require(Thread.isMainThread, "Must be called from main or UI thread")
}

@inline(__always)
public func checkMainThread() throws {
    try check(Thread.isMainThread, "Must be called from main or UI thread")
}

@inline(__always)
public func requireBackgroundThread() throws {
    try require(Thread.isMainThread, "Must be called from Background thread")
}

@inline(__always)
public func checkBackgroundThread() throws {
    try check(Thread.isMainThread, "Must be called from Background thread")
}
