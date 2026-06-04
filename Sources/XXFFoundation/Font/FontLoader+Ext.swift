//
//  FontLoader+Ext.swift
//  xxf_ios
//
//  Created by xxf on 6/4.
//

// MARK: - 其他辅助方法

extension FontLoader {
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

            if fileName.contains(SupportedFontExtensions.trueTypeFont.rawValue) || fileName.contains(FontLoader.SupportedFontExtensions.openTypeFont.rawValue) {
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
            print("[FontLoader]: \(message)")
        }
    }
}
