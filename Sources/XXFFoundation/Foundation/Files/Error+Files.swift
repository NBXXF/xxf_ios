//
//  Error+Files.swift
//  xxf_ios
//  文件操作相关错误
//  Created by xxf on 7/9.
//

import Foundation

public extension Error {
    // MARK: - 文件冲突 / 命名

    /// 是否是文件命名冲突错误
    ///
    /// - 场景：移动、复制或创建文件时，目标路径已有同名文件
    /// - Cocoa 错误码：516 (`NSFileWriteFileExistsError`)
    /// - 示例：尝试在同一目录创建 "file.txt"，已存在时触发
    var isFileDuplicateNameError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain && error.code == NSFileWriteFileExistsError
    }

    // MARK: - 文件不存在

    /// 是否是文件不存在错误
    ///
    /// - 场景：读取、移动、删除文件时，文件路径不存在
    /// - Cocoa 错误码：4 (`NSFileNoSuchFileError`), 260 (`NSFileReadNoSuchFileError`)
    var isFileNotFoundError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain && [NSFileNoSuchFileError, NSFileReadNoSuchFileError].contains(error.code)
    }

    // MARK: - 权限相关

    /// 是否是文件没有写权限错误
    ///
    /// - 场景：写入或修改文件时，当前用户权限不足
    /// - Cocoa 错误码：513 (`NSFileWriteInapplicableStringEncodingError`), 514, 517
    var isFileNoPermissionError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain &&
            [NSFileWriteInapplicableStringEncodingError,
             NSFileWriteUnsupportedSchemeError,
             NSFileWriteNoPermissionError].contains(error.code)
    }

    /// 是否是目标卷只读或文件只读错误
    ///
    /// - 场景：写入或移动文件时，目标卷/文件只读
    /// - Cocoa 错误码：642 (`NSFileWriteVolumeReadOnlyError`)
    var isFileReadOnlyError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain && error.code == NSFileWriteVolumeReadOnlyError
    }

    // MARK: - 磁盘 / 空间相关

    /// 是否是磁盘空间不足错误
    ///
    /// - 场景：写入或复制文件时，磁盘容量不足
    /// - Cocoa 错误码：538 (`NSFileWriteOutOfSpaceError`)
    var isDiskFullError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain && error.code == NSFileWriteOutOfSpaceError
    }

    /// 是否是目标卷只读错误
    ///
    /// - 场景：写入或移动文件时，目标卷被挂载为只读
    /// - Cocoa 错误码：642 (`NSFileWriteVolumeReadOnlyError`)
    var isVolumeReadOnlyError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain && error.code == NSFileWriteVolumeReadOnlyError
    }

    // MARK: - 文件使用 / 占用

    /// 是否是文件正在使用错误
    ///
    /// - 场景：移动、删除或覆盖文件时，该文件被另一个进程占用
    /// - Cocoa 错误码：657 (`NSFileWriteFileBusyError`)
    var isFileBusyError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain && error.code == 657
    }

    // MARK: - 文件名 / 路径

    /// 是否是文件名无效错误
    ///
    /// - 场景：创建或重命名文件时，文件名包含系统不允许的字符
    /// - Cocoa 错误码：640 (`NSFileWriteInvalidFileNameError`)
    var isFileInvalidNameError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain && error.code == NSFileWriteInvalidFileNameError
    }

    /// 是否是文件路径过长错误
    ///
    /// - 场景：创建或访问文件时，路径长度超过系统限制
    /// - Cocoa 错误码：639 (`NSFileWriteFileNameTooLongError`)
    var isFilePathTooLongError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain && error.code == 639
    }

    // MARK: - 读写异常

    /// 是否是未知的文件读取错误
    ///
    /// - 场景：读取文件失败，无法确定具体原因
    /// - Cocoa 错误码：257 (`NSFileReadUnknownError`)
    var isFileReadUnknownError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain && error.code == NSFileReadUnknownError
    }

    /// 是否是未知的文件写入错误
    ///
    /// - 场景：写入文件失败，无法确定具体原因
    /// - Cocoa 错误码：512 (`NSFileWriteUnknownError`)
    var isFileWriteUnknownError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain && error.code == NSFileWriteUnknownError
    }

    /// 是否是文件编码不支持写入错误
    ///
    /// - 场景：尝试写入字符串到文件，但编码不兼容
    /// - Cocoa 错误码：513 (`NSFileWriteInapplicableStringEncodingError`)
    var isFileEncodingUnsupportedError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain && error.code == NSFileWriteInapplicableStringEncodingError
    }

    // MARK: - 通用判断

    /// 是否是常见的文件操作错误（NSCocoaErrorDomain, code 400~699）
    ///
    /// - 场景：可以用于日志统计或统一处理所有文件相关错误
    var isFileError: Bool {
        guard let error = nsError else {
            return false
        }
        return error.domain == NSCocoaErrorDomain && (400 ... 699).contains(error.code)
    }
}
