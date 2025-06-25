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
        // 1️⃣ Send failed, but we may still have reports to analyze
        if let error = error {
            logE { "❌ Failed to send crash reports: \(error.localizedDescription)" }

            if let reports = reports as? [[String: Any]], !reports.isEmpty {
                logE { "⚠️ Send failed, but received \(reports.count) crash report(s). Printing..." }
                let formatted = formatCrashReports(reports)
                for line in formatted {
                    logE { line }
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
}
