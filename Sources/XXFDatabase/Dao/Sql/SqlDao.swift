//
//  SqlDao.swift
//  xxf_ios
//
//  Created by xxf on /6/4.
//
import XXFDataSource

public protocol SqlDao: LocalDataSource, ReadableSqlDao, WritableSqlDao {}
