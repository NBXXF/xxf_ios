import Foundation
import Testing
@testable import XXFServer

@Test func fileResponsePreflightRejectsMissingPath() {
    let missingPath = NSTemporaryDirectory()
        .appending(UUID().uuidString)
        .appending("/missing.html")

    #expect(LocalWebServer.isRegularFileForResponse(atPath: missingPath) == false)
}

@Test func fileResponsePreflightRejectsDirectory() throws {
    let directoryURL = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directoryURL) }

    #expect(LocalWebServer.isRegularFileForResponse(atPath: directoryURL.path) == false)
}

@Test func fileResponsePreflightAcceptsRegularFile() throws {
    let fileURL = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString)
        .appendingPathExtension("html")
    try Data("<html></html>".utf8).write(to: fileURL)
    defer { try? FileManager.default.removeItem(at: fileURL) }

    #expect(LocalWebServer.isRegularFileForResponse(atPath: fileURL.path))
}
