//
//  CrashReporterManager.swift
//  xxf_ios
//  监听闪退,增加日志
//  Created by xxf on 6/25.
//

import Foundation
import KSCrashInstallations

public typealias CrashReportCallback = (_ formattedReports: [String], _ error: Error?) -> Void

/// 监听闪退并写入日志
public final class CrashReporterManager {
    public nonisolated(unsafe) static let shared = CrashReporterManager()
    public var crashReportCallback: CrashReportCallback?

    private init() {}

    public func start() {
        do {
            let installation = CrashInstallationStandard.shared

            // Optional upload URL (not actually used for local logging)
            // installation.url = URL(string: "http://put.your.url.here")!

            let config = KSCrashConfiguration()
            config.monitors = [.machException, .signal] // Monitor crash types

            try installation.install(with: config)

            installation.sendAllReports { reports, error in
                self.sendAllReports(reports: reports, error: error)
            }

        } catch {
            logE { "❌ CrashReporter initialization failed: \(error.localizedDescription)" }
        }
    }

    public func sendAllReports(reports: [Any]?, error: Error?) {
        let logDirectory = LogUtils.getLogDirectoryURL()
        do {
            try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        } catch {}
        let crashFileURL = logDirectory.appendingPathComponent("crash_\(getTimes()).log")

        // 1️⃣ Send failed, but we may still have reports to analyze
        if let error = error {
            let info = "❌ Failed to send crash reports: \(error.localizedDescription)"
            logE { info }
            info.writeSafe(to: crashFileURL, appending: true)

            if let reports = reports as? [[String: Any]], !reports.isEmpty {
                let reportInfo = "⚠️ Send failed, but received \(reports.count) crash report(s). Printing..."
                logE { reportInfo }
                reportInfo.writeSafe(to: crashFileURL, appending: true)

                let formatted = formatCrashReports(reports)
                for line in formatted {
                    logE { line }
                    line.writeSafe(to: crashFileURL, appending: true)
                }
                crashReportCallback?(formatted, error)
            }

            return
        }

        // 2️⃣ Success but no crash reports
        guard let reports = reports as? [[String: Any]], !reports.isEmpty else {
            logE { "Crash report upload completed. No crash reports to send." }
            return
        }

        // 3️⃣ Success with reports
        logE { "Successfully sent \(reports.count) crash report(s):" }
        let formatted = formatCrashReports(reports)
        for line in formatted {
            logE { line }
            line.writeSafe(to: crashFileURL, appending: true)
        }
        crashReportCallback?(formatted, error)
    }

    /// Format crash reports into pretty JSON strings for logging or upload
    public func formatCrashReports(_ reports: [[String: Any]]) -> [String] {
        var result: [String] = []

        for (index, report) in reports.enumerated() {
            var entry = "📄 Crash Report #\(index + 1):\n"

            do {
                let data = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted])
                if let string = String(data: data, encoding: .utf8) {
                    entry += string
                } else {
                    entry += "⚠️ Failed to encode crash report string."
                }
            } catch {
                entry += "⚠️ Failed to serialize crash report: \(error)"
            }

            result.append(entry)
        }

        return result
    }

    private func getTimes() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmssSSS"
        let timestamp = formatter.string(from: Date())
        return timestamp
    }
}

private extension Data {
    /// 写入到指定 URL，如果 `appending == true` 则追加写入，否则覆盖
    func write(to url: URL, appending: Bool) throws {
        if appending, FileManager.default.fileExists(atPath: url.path) {
            let fileHandle = try FileHandle(forWritingTo: url)
            try fileHandle.seekToEnd()
            try fileHandle.write(contentsOf: self)
            try fileHandle.close()
        } else {
            try write(to: url)
        }
    }
}

private extension String {
    private static var lineSeparator: String {
        #if os(Windows)
            return "\r\n"
        #else
            return "\n"
        #endif
    }

    func writeSafe(to url: URL, appending: Bool, encoding: String.Encoding = .utf8) {
        do {
            try write(to: url, appending: appending, encoding: encoding)
        } catch {}
    }

    /// 写入到指定 URL，如果 `appending == true` 则追加写入，否则覆盖
    func write(to url: URL, appending: Bool, encoding: String.Encoding = .utf8) throws {
        let data = "\(String.lineSeparator)\(self)".data(using: encoding) ?? Data()
        try data.write(to: url, appending: appending)
    }
}
