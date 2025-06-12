//
//  LogToplevel.swift
//  xxf_ios
//
//  Created by xxf on /5/23.
//
import Foundation

@inlinable
@inline(__always)
public func logD(_ message: () -> String,
                 tag: String = "General",
                 file: String = #fileID,
                 function: String = #function,
                 line: Int = #line)
{
    LogUtils.log(message, level: .debug, tag: tag, file: file, function: function, line: line)
}

@inlinable
@inline(__always)
public func logI(_ message: () -> String,
                 tag: String = "General",
                 file: String = #fileID,
                 function: String = #function,
                 line: Int = #line)
{
    LogUtils.log(message, level: .info, tag: tag, file: file, function: function, line: line)
}

@inlinable
@inline(__always)
public func logW(_ message: () -> String,
                 tag: String = "General",
                 file: String = #fileID,
                 function: String = #function,
                 line: Int = #line)
{
    LogUtils.log(message, level: .warning, tag: tag, file: file, function: function, line: line)
}

@inlinable
@inline(__always)
public func logE(_ message: () -> String,
                 tag: String = "General",
                 file: String = #fileID,
                 function: String = #function,
                 line: Int = #line)
{
    LogUtils.log(message, level: .error, tag: tag, file: file, function: function, line: line)
}
