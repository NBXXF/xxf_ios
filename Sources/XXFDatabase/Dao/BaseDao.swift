//
//  BaseDao.swift
//  xxf_ios
//  提供通用的dao层
//  Created by xxf on /6/4.
//
import XXFDataSource

public protocol BaseDao: LocalDataSource, ReadableDao, WritableDao {}
