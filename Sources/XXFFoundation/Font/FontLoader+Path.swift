//
//  FontLoader+Path.swift
//  xxf_ios
//
//  Created by xxf on 6/4.
//

// MARK: - 字体加载辅助方法

extension FontLoader {
    /// 加载指定 Bundle 路径下发现的所有字体。
    ///
    /// - Parameter path: Bundle 的绝对路径。
    final class func loadFontsForBundle(withPath path: String) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path) as [String]
            let loadedFonts = fonts(fromPath: path, withContents: contents)
            if !loadedFonts.isEmpty {
                for font in loadedFonts {
                    loadFont(font: font)
                }
            } else {
                printDebugMessage(message: "No fonts were found in the bundle path: \(path).")
            }
        } catch let error as NSError {
            printDebugMessage(message: "There was an error loading fonts from the bundle. \nPath: \(path).\nError: \(error)")
        }
    }

    /// 加载指定 Bundle 内嵌套 Bundle 中发现的所有字体。
    ///
    /// - Parameter path: Bundle 的绝对路径。
    final class func loadFontsFromBundlesFoundInBundle(path: String) {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: path)
            for item in contents {
                if let url = URL(string: path),
                   item.contains(".bundle")
                {
                    let urlPathString = url.appendingPathComponent(item).absoluteString
                    loadFontsForBundle(withPath: urlPathString)
                }
            }
        } catch let error as NSError {
            printDebugMessage(message: "There was an error accessing bundle with path. \nPath: \(path).\nError: \(error)")
        }
    }

    /// 加载指定字体。
    ///
    /// - Parameter font: 要加载的字体。
    final class func loadFont(font: Font) {
        let fontPath: FontPath = font.path
        let fontName: FontName = font.name
        let fontExtension: FontExtension = font.ext
        let fontFileURL = URL(fileURLWithPath: fontPath).appendingPathComponent(fontName).appendingPathExtension(fontExtension)

        var fontError: Unmanaged<CFError>?
        if let fontData = try? Data(contentsOf: fontFileURL) as CFData,
           let dataProvider = CGDataProvider(data: fontData)
        {
            guard let fontRef = CGFont(dataProvider) else {
                printDebugMessage(message: "Failed to load font: '\(fontName)': fontRef is nil")
                return
            }

            if CTFontManagerRegisterGraphicsFont(fontRef, &fontError),
               let postScriptName = fontRef.postScriptName
            {
                printDebugMessage(message: "Successfully loaded font: '\(postScriptName)'.")
                loadedFonts.append(String(postScriptName))
            } else if let fontError = fontError?.takeRetainedValue() {
                let errorDescription = CFErrorCopyDescription(fontError)
                printDebugMessage(message: "Failed to load font '\(fontName)': \(String(describing: errorDescription))")
            }
        } else {
            guard let fontError = fontError?.takeRetainedValue() else {
                printDebugMessage(message: "Failed to load font '\(fontName)'.")
                return
            }

            let errorDescription = CFErrorCopyDescription(fontError)
            printDebugMessage(message: "Failed to load font '\(fontName)': \(String(describing: errorDescription))")
        }
    }
}
