//
//  Row+BaseRow.swift
//  xxf_ios
//
//  Created by xxf on 6/21.
//
import GRDB
import XXFDatabase

extension Row: BaseRow {
    public func value<T>(forColumn column: String) -> T? {
        return self[column] as? T
    }

    public subscript<T>(column: String) -> T? {
        return self[column] as? T
    }
}
