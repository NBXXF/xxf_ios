//
//  NetworkStatus.swift
//  xxf_ios
//  网络状态
//  Created by xxf on 6/29.
//

public enum NetworkStatus: Equatable {
    case connected(NetworkType)
    case disconnected
}
