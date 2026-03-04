//
//  TargetType+Extension.swift
//  xxf_ios
//
//  Created by xxf on 6/23.
//
import Alamofire
import Foundation
import Moya

public extension TargetType {
    /// 完整url
    var url: URL {
        return baseURL.appendingPathComponent(path)
    }
}
