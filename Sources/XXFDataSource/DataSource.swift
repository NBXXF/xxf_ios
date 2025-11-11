//
//  DataSource.swift
//  xxf_ios
//  数据源协议
//  Created by xxf on 6/19.
//

/**
 View / ViewModel
     ↓
 Service（业务逻辑层）
     ↓
 Repository（数据聚合层）
    ├─ LocalDataSource（数据库访问，DAO 封装）
    └─ RemoteDataSource（网络访问，API 封装）
 */

public protocol DataSource {}
