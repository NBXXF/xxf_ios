//
//  BundleToken.swift
//  xxf_ios
//  获取bundle
//  Created by xxf
//

import Foundation

public final class BundleToken {
    public static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }()
}
