//
//  BaseRepository.swift
//  xxf_ios
//  数据库通用Repository，无论底层数据库是objectbox 还是GRDB
//  Created by xxf on 6/3.
//

public protocol BaseRepository: ReadableRepository, WritableRepository {}
