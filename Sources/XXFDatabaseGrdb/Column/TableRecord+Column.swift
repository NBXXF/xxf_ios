//
//  TableRecord+Column.swift
//  xxf_ios
//
//  Created by xxf on 7/15.
//
import GRDB

public extension TableRecord {
    static var allColumnNames: [String] {
        databaseSelection.compactMap { ($0 as? Column)?.name }
    }

    static var allColumns: [Column] {
        databaseSelection.compactMap { ($0 as? Column) }
    }
}
