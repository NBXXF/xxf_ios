//
//  SwiftFormatConfig.swift
//  xxf_ios
//
//  Created by xxf on 2023/11/12.
//

// xxf_ios/XXFSwiftFormat/SwiftFormatConfig.swift
import Foundation

public enum SwiftFormatConfig {
    /// 返回当前包版本下的 .swiftformat 文件路径
    public static var path: String {
        // #filePath 会返回当前 Swift 文件的绝对路径
        let fileURL = URL(fileURLWithPath: #filePath)
        // 替换文件名，指向 .swiftformat
        return fileURL
            .deletingLastPathComponent()
            .appendingPathComponent(".swiftformat")
            .path
    }
}

/**
 配置run脚本
 set -e

 echo "===== [Run Script: SwiftFormat] START ====="

 # 确保 PATH 包含 brew 安装路径
 export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

 # 尝试使用全局 swiftformat
 SWIFTFORMAT_BIN=$(which swiftformat || true)

 # 如果全局没找到，尝试 git hook 目录
 if [ -z "$SWIFTFORMAT_BIN" ]; then
     if [ -f "${SRCROOT}/.git/hooks/bin/swiftformat" ]; then
         SWIFTFORMAT_BIN="${SRCROOT}/.git/hooks/bin/swiftformat"
     fi
 fi

 if [ -z "$SWIFTFORMAT_BIN" ]; then
     echo "warning: SwiftFormat not installed, skipping formatting"
     exit 0
 else
     echo "SwiftFormat found: $SWIFTFORMAT_BIN"
 fi

 # 使用 Swift 执行 SPM 库获取 .swiftformat 路径
 CONFIG_PATH=$(xcrun --find swift -suppress-warnings -target x86_64-apple-macosx12.0 -e "import XXFSwiftFormat; print(XXFSwiftFormat.SwiftFormatConfig.path)")

 echo "Using config: $CONFIG_PATH"

 # 对整个工程根目录执行格式化
 $SWIFTFORMAT_BIN --config "$CONFIG_PATH" "$SRCROOT" --swiftversion 5.9 --verbose

 echo "===== [Run Script: SwiftFormat] END ====="
 */
