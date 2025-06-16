//
//  Preconditions.swift
//  xxf_ios
//  专注于参数校验
//  - require 专注于教研外部参数
//  - check 专注于检查自身
//  Created by xxf on 6/12.
//
@inlinable
@inline(__always)
public func require(_ condition: @autoclosure () -> Bool,
                    _ message: @autoclosure () -> String = "Failed requirement.") throws
{
    guard condition() else {
        throw IllegalArgumentError(message())
    }
}

@inlinable
@inline(__always)
public func check(_ condition: @autoclosure () -> Bool,
                  _ message: @autoclosure () -> String = "Check failed.") throws
{
    guard condition() else {
        throw IllegalStateError(message())
    }
}

@inlinable
@inline(__always)
public func requireNotNil<T>(_ value: T?,
                             _ message: @autoclosure () -> String = "Required value was nil.") throws -> T
{
    guard let v = value else {
        throw IllegalArgumentError(message())
    }
    return v
}

@inlinable
@inline(__always)
public func checkNotNil<T>(_ value: T?,
                           _ message: @autoclosure () -> String = "Checked value was nil.") throws -> T
{
    guard let v = value else {
        throw IllegalStateError(message())
    }
    return v
}

@inlinable
@inline(__always)
public func error(_ message: @autoclosure () -> String) throws -> Never {
    throw IllegalStateError(message())
}
