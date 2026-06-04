//
//  BundleToken.swift
//  xxf_ios
//  获取bundle
//  Created by xxf
//

import Foundation

/// 方式1 Bundle.module 性能更好
//
// public final class BundleToken {
//    public static let bundle: Bundle = {
//        /**
//         必须配置process ,其中"Resources" 是目录
//         .target(
//             name: "MouduleName",
//             resources: [
//                 .process("Resources")
//             ]
//         )
//         */
//        #if SWIFT_PACKAGE
//        return Bundle.module
//        #else
//        return Bundle(for: BundleToken.self)
//        #endif
//    }()
// }

/// 方式2: 每个模块写一个BundleToken空类,业务自己 Bundle(for: BundleToken.self)
public final class BundleToken {}
