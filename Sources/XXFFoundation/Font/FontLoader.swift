//
//  FontLoader.swift
//  FontLoader
//  健壮的字体加载库
//  Created by xxf on 6/4.
//

import CoreGraphics
import CoreText
import Foundation

// MARK: - FontLoader

public final class FontLoader {
    fileprivate enum SupportedFontExtensions: String {
        case trueTypeFont = ".ttf"
        case openTypeFont = ".otf"
    }

    fileprivate typealias FontPath = String
    fileprivate typealias FontName = String
    fileprivate typealias FontExtension = String
    fileprivate typealias Font = (path: FontPath, name: FontName, ext: FontExtension)

    /// 是否开启调试日志输出。
    public static var debugEnabled = false

    /// 已加载的字体名称列表。
    public static var loadedFonts: [String] = []

    /// 加载指定 Bundle 中发现的所有字体。未传入 Bundle 时，默认使用主 Bundle。
    public class func load(bundle: Bundle = Bundle.main) {
        load(bundle: bundle, completion: nil)
    }

    /**
     加载指定 Bundle 中发现的所有字体。未传入 Bundle 时，默认使用主 Bundle。

     - returns: 包含已加载字体名称的字符串数组。
     */
    public class func load(bundle: Bundle = Bundle.main, completion handler: (([String]) -> Void)?) {
        let path = bundle.bundlePath
        loadFontsForBundle(withPath: path)
        loadFontsFromBundlesFoundInBundle(path: path)
        handler?(loadedFonts)
    }
}
