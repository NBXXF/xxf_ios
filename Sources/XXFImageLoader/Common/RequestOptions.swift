//
//  RequestOptions.swift
//  xxf_ios
//
//  Created by xxf on 8/19.
//
import CoreGraphics
import Foundation
import XXFFoundation

public class RequestOptions: @unchecked Sendable {
    /// 移除添加的参数
    public class func removeOptions(url: URL) -> URL {
        return url.removeParameters(ImageLoaderConfigKeys.allCases.map(\.rawValue))
    }

    var requestTargetSize: CGSize

    var requsetRepresentationType: RepresentationType

    public init(requestTargetSize: CGSize = CGSize.zero, requsetPepresentationType: RepresentationType = .all) {
        self.requestTargetSize = requestTargetSize
        requsetRepresentationType = requsetPepresentationType
    }

    /// 从 URL 的 query 构造
    /// 例如: ?width=100&height=200&type=1
    init(url: URL) {
        let params = url.queryParameters

        if let widthStr = params[ImageLoaderConfigKeys.keyOverrideWidth.rawValue],
           let width = Double(widthStr),
           let heightStr = params[ImageLoaderConfigKeys.keyOverrideHeight.rawValue],
           let height = Double(heightStr)
        {
            requestTargetSize = CGSize(width: width, height: height)
        } else {
            requestTargetSize = .zero
        }

        if let typeStr = params[ImageLoaderConfigKeys.keyRepresentationType.rawValue],
           let typeRaw = Int(typeStr),
           let type = RepresentationType(rawValue: typeRaw)
        {
            requsetRepresentationType = type
        } else {
            requsetRepresentationType = .all
        }
    }

    /// 裁切大小
    /// - Parameter size: 大小
    /// - Returns: 字节
    @discardableResult
    public func overrideSize(_ size: CGSize) -> Self {
        requestTargetSize = size
        return self
    }

    /// 加载优先级
    /// - Parameter type: 优先级
    /// - Returns: 字节
    @discardableResult
    public func representationType(_ type: RepresentationType) -> Self {
        requsetRepresentationType = type
        return self
    }

    func toOptoionDict() -> [String: String] {
        var dict: [String: String] = [:]
        if requestTargetSize != .zero {
            dict[ImageLoaderConfigKeys.keyOverrideWidth.rawValue] = "\(requestTargetSize.width)"
            dict[ImageLoaderConfigKeys.keyOverrideHeight.rawValue] = "\(requestTargetSize.height)"
        }
        dict[ImageLoaderConfigKeys.keyRepresentationType.rawValue] = String(requsetRepresentationType.rawValue)
        return dict
    }
}
