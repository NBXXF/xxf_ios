//
//  BaseApiService.swift
//  xxf_ios
//  封装基础apiService,业务只需要继承这个就行了
//  Created by xxf on /6/9.
//
import Moya
import XXFDataSource

public protocol BaseApiService: TargetType, RemoteDataSource, UserClientAdapterAnnotatable {}
