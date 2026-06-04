//
//  FontRegister.swift
//  FontRegister
//  健壮的字体注册库
//  Created by xxf on 6/4.
//

import CoreGraphics
import CoreText
import Foundation

// MARK: - FontRegister

public final class FontRegister {
    fileprivate enum SupportedFontExtensions: String {
        case trueTypeFont = ".ttf"
        case openTypeFont = ".otf"
    }

    fileprivate typealias FontPath = String
    fileprivate typealias FontName = String
    fileprivate typealias FontExtension = String
    fileprivate typealias Font = (path: FontPath, name: FontName, ext: FontExtension)

    /// 是否开启调试日志输出。
    nonisolated(unsafe)
    public static var debugEnabled = false

    /// 已注册的字体名称列表。
    nonisolated(unsafe)
    public static var registeredFonts: [String] = []

    /// 注册指定 Bundle 中发现的所有字体。未传入 Bundle 时，默认使用主 Bundle。
    public class func register(bundle: Bundle = Bundle.main) {
        register(bundle: bundle, completion: nil)
    }

    /**
     注册指定 Bundle 中发现的所有字体。未传入 Bundle 时，默认使用主 Bundle。

     - returns: 包含已注册字体名称的字符串数组。
     */
    public class func register(bundle: Bundle = Bundle.main, completion handler: (([String]) -> Void)?) {
        let path = bundle.bundlePath
        registerFontsForBundle(withPath: path)
        registerFontsFromBundlesFoundInBundle(path: path)
        handler?(registeredFonts)
    }
}

// MARK: - 字体注册辅助方法

private extension FontRegister {
    /// 注册指定 Bundle 路径下发现的所有字体。
    ///
    /// - Parameter path: Bundle 的绝对路径。
    final class func registerFontsForBundle(withPath path: String) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path) as [String]
            let discoveredFonts = fonts(fromPath: path, withContents: contents)
            if !discoveredFonts.isEmpty {
                for font in discoveredFonts {
                    registerFont(font: font)
                }
            } else {
                printDebugMessage(message: "No fonts were found in the bundle path: \(path).")
            }
        } catch let error as NSError {
            printDebugMessage(message: "There was an error registering fonts from the bundle. \nPath: \(path).\nError: \(error)")
        }
    }

    /// 注册指定 Bundle 内嵌套 Bundle 中发现的所有字体。
    ///
    /// - Parameter path: Bundle 的绝对路径。
    final class func registerFontsFromBundlesFoundInBundle(path: String) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path)
            for item in contents {
                if let url = URL(string: path),
                   item.contains(".bundle")
                {
                    let urlPathString = url.appendingPathComponent(item).absoluteString
                    registerFontsForBundle(withPath: urlPathString)
                }
            }
        } catch let error as NSError {
            printDebugMessage(message: "There was an error accessing bundle with path. \nPath: \(path).\nError: \(error)")
        }
    }

    /// 注册指定字体。
    ///
    /// - Parameter font: 要注册的字体。
    final class func registerFont(font: Font) {
        let fontPath: FontPath = font.path
        let fontName: FontName = font.name
        let fontExtension: FontExtension = font.ext
        let fontFileURL = URL(fileURLWithPath: fontPath).appendingPathComponent(fontName).appendingPathExtension(fontExtension)

        var fontError: Unmanaged<CFError>?
        if let fontData = try? Data(contentsOf: fontFileURL) as CFData,
           let dataProvider = CGDataProvider(data: fontData)
        {
            guard let fontRef = CGFont(dataProvider) else {
                printDebugMessage(message: "Failed to register font: '\(fontName)': fontRef is nil")
                return
            }

            if CTFontManagerRegisterGraphicsFont(fontRef, &fontError),
               let postScriptName = fontRef.postScriptName
            {
                printDebugMessage(message: "Successfully registered font: '\(postScriptName)'.")
                registeredFonts.append(String(postScriptName))
            } else if let fontError = fontError?.takeRetainedValue() {
                let errorDescription = CFErrorCopyDescription(fontError)
                printDebugMessage(message: "Failed to register font '\(fontName)': \(String(describing: errorDescription))")
            }
        } else {
            guard let fontError = fontError?.takeRetainedValue() else {
                printDebugMessage(message: "Failed to register font '\(fontName)'.")
                return
            }

            let errorDescription = CFErrorCopyDescription(fontError)
            printDebugMessage(message: "Failed to register font '\(fontName)': \(String(describing: errorDescription))")
        }
    }
}

// MARK: - 其他辅助方法

private extension FontRegister {
    /// 将所有字体解析成名称和扩展名组件。
    ///
    /// - Parameters:
    ///   - path: 字体文件的绝对路径。
    ///   - contents: Bundle 内容列表。
    ///
    /// - Returns: Font 对象数组。
    final class func fonts(fromPath path: String, withContents contents: [String]) -> [Font] {
        printDebugMessage(message: "\nScanning \(path) with contents: \n \(contents)")
        var fonts = [Font]()
        for fileName in contents {
            var parsedFont: (FontName, FontExtension)?

            if fileName.contains(SupportedFontExtensions.trueTypeFont.rawValue) || fileName.contains(FontRegister.SupportedFontExtensions.openTypeFont.rawValue) {
                parsedFont = font(fromName: fileName)
            }

            if let parsedFont = parsedFont {
                let font: Font = (path, parsedFont.0, parsedFont.1)
                fonts.append(font)
            }

            let fileURL = URL(fileURLWithPath: "\(path)/\(fileName)")
            let isDir = (
                try? fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory
            ) ?? false

            if isDir {
                let contents: [String] = (
                    try? FileManager.default.contentsOfDirectory(atPath: fileURL.path)
                ) ?? []
                let subDirFonts = Self.fonts(fromPath: fileURL.path,
                                             withContents: contents)
                fonts.append(contentsOf: subDirFonts)
            }
        }

        return fonts
    }

    /// 将字体文件名解析成名称和扩展名组件。
    ///
    /// - Parameter name: 字体文件名。
    ///
    /// - Returns: 包含字体名称和扩展名的元组。
    final class func font(fromName name: String) -> (FontName, FontExtension) {
        let components = name.split { $0 == "." }.map { String($0) }
        return (components[0], components[1])
    }

    /// 当 debugEnabled 为 true 时，向控制台输出调试信息。
    ///
    /// - Parameter message: 要输出到控制台的状态信息。
    final class func printDebugMessage(message: String) {
        if debugEnabled {
            print("[FontRegister]: \(message)")
        }
    }
}
